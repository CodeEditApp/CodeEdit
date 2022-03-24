//
//  GitCloneView.swift
//  CodeEdit
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import GitClient
import Foundation

struct GitCloneView: View {
    var windowController: NSWindowController
    @State private var repoUrl = ""
    @State private var repoPath = "~/"
    // TODO: localize
    @State private var alertText = "Url cannot be empty"
    @State private var alertInfo = "You need to provide a valid git url"
    var body: some View {
        VStack(spacing: 8) {
            Text("Clone existing repository")
                .padding(.top, 10)
            HStack(spacing: 8) {
                TextField("Select target folder", text: $repoPath)
                Button("Browse") {
                    getPath()
                }
            }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            HStack(spacing: 8) {
                TextField("Git Repository URL", text: $repoUrl)
                    .lineLimit(1)
                    .foregroundColor(.black)
                Button("Clone") {
                    do {
                        if repoUrl == "" {
                            showAlert(alertMsg: alertText, infoText: alertInfo)
                            return
                        }
                        let dirUrl = URL(string: repoPath)
                        // TODO: check for git errors also.
                        // For example if the response contains `fatal` etc.
                        try GitClient.default(directoryURL: dirUrl!).cloneRepository(repoUrl)
                        windowController.window?.close()
                        CodeEditDocumentController.shared.openDocument(self)

                    } catch let error {
                        print(error)
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
    func getPath() {
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
                repoPath = path
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
