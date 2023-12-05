//
//  SourceControlNavigatorChangesCommitView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/19/23.
//

import SwiftUI

struct SourceControlNavigatorChangesCommitView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @State private var message: String = ""
    @State private var details: String = ""
    @State private var ammend: Bool = false
    @State private var showDetails: Bool = false
    @State private var isCommiting: Bool = false

    var allFilesStaged: Bool {
        sourceControlManager.changedFiles.allSatisfy { $0.staged ?? false }
    }

    var anyFilesStaged: Bool {
        sourceControlManager.changedFiles.contains { $0.staged ?? false }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                PaneTextField(
                    "Commit message (required)",
                    text: $message,
                    axis: .vertical
                )
                .lineLimit(1...3)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if showDetails {
                        VStack {
                            TextField(
                                "Detailed description",
                                text: $details,
                                axis: .vertical
                            )
                            .textFieldStyle(.plain)
                            .controlSize(.small)
                            .lineLimit(3...5)

                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3.5)
                        .overlay(alignment: .top) {
                            VStack {
                                Divider()
                            }
                        }
                    }
                }
                VStack(spacing: 0) {
                    if showDetails {
                        Toggle(isOn: $ammend) {
                            Text("Amend")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                HStack(spacing: 8) {
                    Button {
                        Task {
                            if allFilesStaged {
                                try await sourceControlManager.reset(sourceControlManager.changedFiles)
                            } else {
                                try await sourceControlManager.add(sourceControlManager.changedFiles)
                            }
                        }
                    } label: {
                        Text(allFilesStaged ? "Unstage All" : "Stage All")
                            .frame(maxWidth: .infinity)
                    }
                    Menu(isCommiting ? "Committing..." : "Commit") {
                        Button("Commit and Push...") {
                            Task {
                                self.isCommiting = true
                                do {
                                    try await sourceControlManager.commit(message: message, details: details)
                                    self.message = ""
                                    self.details = ""
                                } catch {
                                    await sourceControlManager.showAlertForError(
                                        title: "Failed to commit",
                                        error: error
                                    )
                                }
                                do {
                                    try await sourceControlManager.push()
                                } catch {
                                    await sourceControlManager.showAlertForError(title: "Failed to push", error: error)
                                }
                                self.isCommiting = false
                            }
                        }
                    } primaryAction: {
                        Task {
                            self.isCommiting = true
                            do {
                                try await sourceControlManager.commit(message: message, details: details)
                                self.message = ""
                                self.details = ""
                            } catch {
                                await sourceControlManager.showAlertForError(title: "Failed to commit", error: error)
                            }
                            self.isCommiting = false
                        }
                    }
                    .disabled(
                        message.isEmpty ||
                        !anyFilesStaged ||
                        isCommiting
                    )
                }
                .padding(.top, 8)
            }
            .transition(.move(edge: .top))
            .onChange(of: message) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    showDetails = !message.isEmpty
                }
            }
        }
    }
}
