//
//  GitCloneView.swift
//  CodeEdit
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import GitClient
import Foundation

public struct GitCloneView: View {
    var windowController: NSWindowController
    @State private var repoUrl = ""
    @State private var repoPath = "~/"
    public init(windowController: NSWindowController) {
        self.windowController = windowController
    }
    public var body: some View {
        VStack(spacing: 8) {
            Text("Clone existing repository")
                .padding(.top, 10)
            HStack(spacing: 8) {
                TextField("Select target folder", text: $repoPath)
                Button("Browse") {
                    getPath(modifiable: &repoPath)
                }
            }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            HStack(spacing: 8) {
                TextField("Git Repository URL", text: $repoUrl)
                    .lineLimit(1)
                Button("Clone") {
                    do {
                        if repoUrl == "" {
                            showAlert(alertMsg: "Url cannot be empty",
                                      infoText: "You must specify a repository to clone")
                        }
                        let dirUrl = URL(string: repoPath)
                        try GitClient.default(directoryURL: dirUrl!).cloneRepository(repoUrl)
                        windowController.window?.close()
                        NSDocumentController.shared.openDocument(repoPath)
                    } catch {
                        guard let error = error as? GitClient.GitClientError else { return }
                        switch error {
                        case let .outputError(message):
                            showAlert(alertMsg: "Error", infoText: message)
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
    func getPath(modifiable: inout String) {
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true

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
