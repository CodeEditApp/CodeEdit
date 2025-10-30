//
//  GitCloneViewModel.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/17/23.
//

import Foundation
import AppKit

class GitCloneViewModel: ObservableObject {
    @Published var repoUrlStr = ""
    @Published var isCloning: Bool = false
    @Published var cloningProgress: GitClient.CloneProgress = .init(progress: 0, state: .initialState)

    var gitClient: GitClient?
    var cloningTask: Task<Void, Error>?

    /// Check if url is valid
    /// - Parameter url: Url to check
    /// - Returns: True if url is valid
    func isValidUrl(url: String) -> Bool {
        // Doing the same kind of check that Xcode does when cloning
        let url = url.lowercased()
        if url.starts(with: "http://") && url.count > 7 {
            return true
        } else if url.starts(with: "https://") && url.count > 8 {
            return true
        } else if url.starts(with: "git@") && url.count > 4 {
            return true
        }
        return false
    }
    /// Check if Git is installed
    /// - Returns: True if Git is found by running "which git" command
    func isGitInstalled() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["git"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Check if clipboard contains git url
    func checkClipboard() {
        if let url = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            if isValidUrl(url: url) {
                self.repoUrlStr = url
            }
        }
    }

    /// Clone repository
    func cloneRepository(completionHandler: @escaping (URL) -> Void) {
        if !isGitInstalled() {
            showAlert(
                alertMsg: "Git installation not found.",
                infoText: "Ensure Git is installed on your system and try again."
            )
            return
        }
        if repoUrlStr == "" {
            showAlert(
                alertMsg: "Url cannot be empty",
                infoText: "You must specify a repository to clone"
            )
            return
        }

        // Parsing repo name
        guard let remoteUrl = URL(string: repoUrlStr) else {
            return
        }

        var repoName = remoteUrl.lastPathComponent

        // Strip .git from name if it has it.
        // Cloning repository without .git also works
        if repoName.contains(".git") {
            repoName.removeLast(4)
        }

        guard let localPath = getPath(saveName: repoName) else {
            return
        }

        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: localPath.relativePath, isDirectory: &isDir) {
            showAlert(alertMsg: "Error", infoText: "Directory already exists")
            return
        }

        do {
            try FileManager.default.createDirectory(
                atPath: localPath.relativePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            showAlert(alertMsg: "Failed to create folder", infoText: "\(error)")
            return
        }

        gitClient = GitClient(directoryURL: localPath, shellClient: .live())

        self.cloningTask = Task(priority: .background) {
            await processCloning(
                remoteUrl: remoteUrl,
                localPath: localPath,
                completionHandler: completionHandler
            )
        }
    }

    /// Process cloning
    /// - Parameters:
    ///   - remoteUrl: Path to remote repository
    ///   - localPath: Path to local folder
    ///   - completionHandler: Completion handler if cloning is successful
    private func processCloning(
        remoteUrl: URL,
        localPath: URL,
        completionHandler: @escaping (URL) -> Void
    ) async {
        guard let gitClient else { return }

        await setIsCloning(true)

        do {
            for try await progress in gitClient.cloneRepository(remoteUrl: remoteUrl, localPath: localPath) {
                await MainActor.run {
                    self.cloningProgress = progress
                }
            }

            if Task.isCancelled {
                await MainActor.run {
                    deleteTemporaryFolder(localPath: localPath)
                }
                return
            }

            completionHandler(localPath)
        } catch {
            await MainActor.run {
                if let error = error as? GitClient.GitClientError {
                    showAlert(alertMsg: "Failed to clone", infoText: error.description)
                } else {
                    showAlert(alertMsg: "Failed to clone", infoText: error.localizedDescription)
                }
                deleteTemporaryFolder(localPath: localPath)
            }
        }

        await setIsCloning(false)
    }

    private func deleteTemporaryFolder(localPath: URL) {
        do {
            try FileManager.default.removeItem(atPath: localPath.relativePath)
        } catch {
            showAlert(alertMsg: "Failed to delete folder", infoText: "\(error)")
            return
        }
    }

    @MainActor
    private func setIsCloning(_ newValue: Bool) {
        self.isCloning = newValue
    }

    private func getPath(saveName: String) -> URL? {
        let dialog = NSSavePanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.showsTagField = false
        dialog.prompt = "Clone"
        dialog.nameFieldStringValue = saveName
        dialog.nameFieldLabel = "Clone as"
        dialog.title = "Clone a Repository"

        guard dialog.runModal() == NSApplication.ModalResponse.OK,
              let result = dialog.url else {
            return nil
        }

        return result
    }

    private func showAlert(alertMsg: String, infoText: String) {
        let alert = NSAlert()
        alert.messageText = alertMsg
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
}
