//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI
import CryptoKit

struct FileCommands: Commands {

    @State var windowController: CodeEditWindowController?

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {
                    guard let workspace = windowController?.workspace else {
                        return
                    }

                    do {
                        try filemanager.createDirectory(at: workspace.supportDirURL, withIntermediateDirectories: true)
                        let supportPath = workspace.supportDirURL.path(percentEncoded: false)
                        let fileNumbers = try filemanager.contentsOfDirectory(atPath: supportPath)
                            .compactMap { return $0.split(separator: "-").last }
                            .compactMap { Int($0) }
                            .sorted()

                        var expectedNum = fileNumbers.first ?? 0
                        for number in fileNumbers {
                            if expectedNum != number {
                                break
                            }
                            expectedNum += 1
                        }

                        let filename = "untitled-\(expectedNum)"
                        let tempFileURL = workspace.supportDirURL.appending(path: filename)
                        filemanager.createFile(atPath: tempFileURL.path(percentEncoded: false), contents: nil)
                        let file = WorkspaceClient.FileItem(url: tempFileURL)
                        windowController?.workspace?.tabManager.openTab(item: file)
                    } catch {
                        print(error)
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = "An error occurred. Please try again later."
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
                .disabled(windowController == nil)
                .keyboardShortcut("n")
                .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                    windowController = window?.windowController as? CodeEditWindowController
                }

                Button("Open...") {
                    NSDocumentController.shared.openDocument(nil)
                }
                .keyboardShortcut("o")

                // Leave this empty, is done through a hidden API in WindowCommands/Utils/CommandsFixes.swift
                // This can't be done in SwiftUI Commands yet, as they don't support images in menu items.
                Menu("Open Recent") {}

                Button("Open Quickly") {
                    NSApp.sendAction(#selector(CodeEditWindowController.openQuickly(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }

        CommandGroup(replacing: .saveItem) {
            Button("Close Tab") {
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
            .keyboardShortcut("w")

            Button("Close Editor") {

            }
            .keyboardShortcut("w", modifiers: [.control, .shift, .command])

            Button("Close Window") {

            }
            .keyboardShortcut("w", modifiers: [.shift, .command])

            Button("Close Workspace") {

            }
            .keyboardShortcut("w", modifiers: [.control, .option, .command])

            Divider()

            Button("Save") {
                NSApp.sendAction(#selector(CodeEditWindowController.saveDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("s")
        }
    }
}
