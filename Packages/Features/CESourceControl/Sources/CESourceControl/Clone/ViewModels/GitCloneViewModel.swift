//
//  GitCloneViewModel.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/17/23.
//

import CodeEditCore
import Foundation
import AppKit

@MainActor
class GitCloneViewModel: ObservableObject {
    @Published var repoUrlStr = ""
    @Published var isCloning: Bool = false
    @Published var cloningProgress: GitClient.CloneProgress = .init(progress: 0, state: .initialState)

    var cloningTask: Task<Void, Error>?

    let shellClient: ShellClientProtocol
    private let useCase: CloneRepositoryUseCase

    init(shellClient: ShellClientProtocol) {
        self.shellClient = shellClient
        self.useCase = CloneRepositoryUseCase(shellClient: shellClient)
    }

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
        do {
            try useCase.verifyGitInstalled()
        } catch {
            showAlert(alertMsg: "Git installation not found.", infoText: error.localizedDescription)
            return
        }

        let parsed: (remoteUrl: URL, suggestedName: String)
        do {
            parsed = try useCase.parse(repoUrl: repoUrlStr)
        } catch {
            showAlert(alertMsg: "Invalid URL", infoText: error.localizedDescription)
            return
        }

        guard let localPath = getPath(saveName: parsed.suggestedName) else {
            return
        }

        let progressStream: AsyncThrowingMapSequence<GitClient.LiveCommandStream, GitClient.CloneProgress>
        do {
            progressStream = try useCase.execute(remoteUrl: parsed.remoteUrl, localPath: localPath)
        } catch {
            showAlert(alertMsg: "Failed to clone", infoText: error.localizedDescription)
            return
        }

        cloningTask = Task(priority: .background) { [weak self] in
            await self?.consumeProgress(
                stream: progressStream,
                localPath: localPath,
                completionHandler: completionHandler
            )
        }
    }

    @MainActor
    private func consumeProgress(
        stream: AsyncThrowingMapSequence<GitClient.LiveCommandStream, GitClient.CloneProgress>,
        localPath: URL,
        completionHandler: @escaping (URL) -> Void
    ) async {
        isCloning = true
        defer { isCloning = false }

        do {
            for try await progress in stream {
                self.cloningProgress = progress
            }

            if Task.isCancelled {
                deleteTemporaryFolder(localPath: localPath)
                return
            }

            completionHandler(localPath)
        } catch {
            if let error = error as? GitClient.GitClientError {
                showAlert(alertMsg: "Failed to clone", infoText: error.description)
            } else {
                showAlert(alertMsg: "Failed to clone", infoText: error.localizedDescription)
            }
            deleteTemporaryFolder(localPath: localPath)
        }
    }

    private func deleteTemporaryFolder(localPath: URL) {
        do {
            try useCase.cleanup(localPath: localPath)
        } catch {
            showAlert(alertMsg: "Failed to delete folder", infoText: "\(error)")
        }
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
