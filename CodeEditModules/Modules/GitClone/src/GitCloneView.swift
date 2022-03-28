//
//  GitCloneView.swift
//  CodeEdit
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import GitClient
import Foundation
import ShellClient

public struct GitCloneView: View {
    var windowController: NSWindowController
    var shellClient: ShellClient
    @State private var repoUrlStr = ""
    @State private var repoPath = "~/"
    public init(windowController: NSWindowController, shellClient: ShellClient) {
        self.windowController = windowController
        self.shellClient = shellClient
    }
    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Git Repository URL", text: $repoUrlStr)
                    .lineLimit(1)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                Button("Clone") {
                    do {
                        if repoUrlStr == "" {
                            showAlert(alertMsg: "Url cannot be empty",
                                      infoText: "You must specify a repository to clone")
                            return
                        }
                        // Parsing repo name
                        let repoURL = URL(string: repoUrlStr)
                        var repoName = repoURL!.lastPathComponent
                        // Strip .git from name if it has it.
                        // Cloning repository without .git also works
                        if repoName.contains(".git") {
                            repoName.removeLast(4)
                        }
                        getPath(modifiable: &repoPath, saveName: repoName)
                        let dirUrl = URL(string: repoPath)
                        var isDir: ObjCBool = true
                        if FileManager.default.fileExists(atPath: repoPath, isDirectory: &isDir) {
                            showAlert(alertMsg: "Error", infoText: "Directory already exists")
                            return
                        }
                        try FileManager.default.createDirectory(atPath: repoPath,
                                                                withIntermediateDirectories: true,
                                                                attributes: nil)
                        try GitClient.default(directoryURL: dirUrl!,
                                              shellClient: shellClient).cloneRepository(repoUrlStr)
                        // TODO: Maybe add possibility to checkout to certain branch straight after cloning
                        windowController.window?.close()
                    } catch {
                        guard let error = error as? GitClient.GitClientError else {
                            return showAlert(alertMsg: "Error", infoText: error.localizedDescription)
                        }
                        switch error {
                        case let .outputError(message):
                            showAlert(alertMsg: "Error", infoText: message)
                        case .notGitRepository:
                            showAlert(alertMsg: "Error", infoText: "Not git repository")
                        }
                    }
                }
                Button("Cancel") {
                    windowController.window?.close()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}

extension GitCloneView {
    func getPath(modifiable: inout String, saveName: String) {
        let dialog = NSSavePanel()
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.showsTagField = false
        dialog.prompt = "Clone"
        dialog.nameFieldStringValue = saveName
        dialog.nameFieldLabel = "Clone as"
        dialog.title = "Clone"

        if dialog.runModal() ==  NSApplication.ModalResponse.OK {
            let result = dialog.url

            if result != nil {
                let path: String = result!.path
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
                modifiable = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }

    }
    func showAlert(alertMsg: String, infoText: String) {
        let alert = NSAlert()
        alert.messageText = alertMsg
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
}
