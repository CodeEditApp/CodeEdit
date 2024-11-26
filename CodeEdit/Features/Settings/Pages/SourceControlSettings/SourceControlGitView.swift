//
//  SourceControlGitView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGitView: View {
    @AppSettings(\.sourceControl.git)
    var git

    let gitConfig = GitConfigClient(shellClient: currentWorld.shellClient)

    @State private var authorName: String = ""
    @State private var authorEmail: String = ""
    @State private var preferRebaseWhenPulling: Bool = false
    @State private var hasAppeared: Bool = false

    var body: some View {
        SettingsForm {
            Section {
                gitAuthorName
                gitEmail
            }
            Section {
                preferToRebaseWhenPulling
                showMergeCommitsInPerFileLog
            } footer: {
                Button("Open in Editor...", action: openGitConfigFile)
            }
            Section {
                IgnoredFilesListView()
            } header: {
                Text("Ignored Files")
            } footer: {
                Button("Open in Editor...", action: openGitIgnoreFile)
            }
        }
        .onAppear {
            Task {
                authorName = try await gitConfig.get(key: "user.name", global: true) ?? ""
                authorEmail = try await gitConfig.get(key: "user.email", global: true) ?? ""
                preferRebaseWhenPulling = try await gitConfig.get(key: "pull.rebase", global: true) ?? false
                try? await Task.sleep(for: .milliseconds(0))
                hasAppeared = true
            }
        }
    }
}

private extension SourceControlGitView {
    private var gitAuthorName: some View {
        TextField("Author Name", text: $authorName)
            .onChange(of: authorName) { newValue in
                if hasAppeared {
                    Limiter.debounce(id: "authorNameDebouncer", duration: 0.5) {
                        Task {
                            await gitConfig.set(key: "user.name", value: newValue, global: true)
                        }
                    }
                }
            }
    }

    private var gitEmail: some View {
        TextField("Author Email", text: $authorEmail)
            .onChange(of: authorEmail) { newValue in
                if hasAppeared {
                    Limiter.debounce(id: "authorEmailDebouncer", duration: 0.5) {
                        Task {
                            await gitConfig.set(key: "user.email", value: newValue, global: true)
                        }
                    }
                }
        }
    }

    private var preferToRebaseWhenPulling: some View {
        Toggle(
            "Prefer to rebase when pulling",
            isOn: $preferRebaseWhenPulling
        )
        .onChange(of: preferRebaseWhenPulling) { newValue in
            if hasAppeared {
                Limiter.debounce(id: "pullRebaseDebouncer", duration: 0.5) {
                    Task {
                        print("Setting pull.rebase to \(newValue)")
                        await gitConfig.set(key: "pull.rebase", value: newValue, global: true)
                    }
                }
            }
        }
    }

    private var showMergeCommitsInPerFileLog: some View {
        Toggle(
            "Show merge commits in per-file log",
            isOn: $git.showMergeCommitsPerFileLog
        )
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
            Button {} label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.secondary)
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "minus")
            }
            .disabled(true)
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private func openGitConfigFile() {
        let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".gitconfig")

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        NSDocumentController.shared.openDocument(
            withContentsOf: fileURL,
            display: true
        ) { _, _, error in
            if let error = error {
                print("Failed to open document: \(error.localizedDescription)")
            }
        }
    }

    private func openGitIgnoreFile() {
        Task {
            // Get the `core.excludesfile` configuration
            let excludesfile: String? = try await gitConfig.get(key: "core.excludesfile")

            // Determine the file URL
            let fileURL: URL
            if let excludesfile, !excludesfile.isEmpty {
                if excludesfile.starts(with: "~/") {
                    // If the path starts with "~/", expand it to the home directory
                    let relativePath = String(excludesfile.dropFirst(2)) // Remove "~/"
                    fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(relativePath)
                } else if excludesfile.starts(with: "/") {
                    // If the path is absolute, use it directly
                    fileURL = URL(fileURLWithPath: excludesfile)
                } else {
                    // Assume it's relative to the home directory
                    fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(excludesfile)
                }
            } else {
                // Fallback to `.gitignore_global` in the home directory
                fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".gitignore_global")
                // Set the default path in Git config if not set
                await gitConfig.set(key: "core.excludesfile", value: "~/\(fileURL.lastPathComponent)", global: true)
            }

            // Ensure the file exists
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }

            // Open the file in the editor
            NSDocumentController.shared.openDocument(
                withContentsOf: fileURL,
                display: true
            ) { _, _, error in
                if let error = error {
                    print("Failed to open document: \(error.localizedDescription)")
                }
            }
        }
    }
}
