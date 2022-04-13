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
    private let shellClient: ShellClient
    @Binding private var isPresented: Bool
    @State private var repoUrlStr = ""
    @State private var repoPath = "~/"
    public init(shellClient: ShellClient, isPresented: Binding<Bool>) {
        self.shellClient = shellClient
        self._isPresented = isPresented
    }
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.bottom, 50)
                VStack(alignment: .leading) {
                    Text("Clone an existing repository")
                        .bold()
                        .padding(.bottom, 2)
                    Text("Enter a git repository URL:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .alignmentGuide(.trailing) { context in
                        context[.trailing]
                    }
                    TextField("Git Repository URL", text: $repoUrlStr)
                        .lineLimit(1)
                        .padding(.bottom, 15)
                        .frame(width: 300)
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        Button("Clone") {
                            cloneRepository()
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(!isValid(url: repoUrlStr))
                    }
                    .offset(x: 185)
                    .alignmentGuide(.leading) { context in
                        context[.leading]
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .onAppear {
                self.checkClipboard(textFieldText: &repoUrlStr)
            }
        }
    }
}

extension GitCloneView {
    func getPath(modifiable: inout String, saveName: String) -> String? {
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
                return path
            }
        } else {
            // User clicked on "Cancel"
            return nil
        }
        return nil
    }
    func showAlert(alertMsg: String, infoText: String) {
        let alert = NSAlert()
        alert.messageText = alertMsg
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
    func isValid(url: String) -> Bool {
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
    func checkClipboard(textFieldText: inout String) {
        if let url = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            if isValid(url: url) {
                textFieldText = url
            }
        }
    }
    private func cloneRepository() {
        do {
            if repoUrlStr == "" {
                showAlert(alertMsg: "Url cannot be empty",
                          infoText: "You must specify a repository to clone")
                return
            }
            // Parsing repo name
            let repoURL = URL(string: repoUrlStr)
            if var repoName = repoURL?.lastPathComponent {
                // Strip .git from name if it has it.
                // Cloning repository without .git also works
                if repoName.contains(".git") {
                    repoName.removeLast(4)
                }
                guard getPath(modifiable: &repoPath, saveName: repoName) != nil else {
                    return
                }
            } else {
                return
            }
            guard let dirUrl = URL(string: repoPath) else {
                return
            }
            var isDir: ObjCBool = true
            if FileManager.default.fileExists(atPath: repoPath, isDirectory: &isDir) {
                showAlert(alertMsg: "Error", infoText: "Directory already exists")
                return
            }
            try FileManager.default.createDirectory(atPath: repoPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            try GitClient.default(directoryURL: dirUrl,
                                  shellClient: shellClient).cloneRepository(repoUrlStr)
            // TODO: Maybe add possibility to checkout to certain branch straight after cloning
            isPresented = false
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
}
