//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FileCommands: Commands {

    @FocusedObject var utilityAreaViewModel: UtilityAreaViewModel?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {
                    createNewFile()
                }
                .keyboardShortcut("n")

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
                NSApp.sendAction(#selector(CodeEditWindowController.closeCurrentTab(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("w")

            Button("Close Editor") {
                NSApp.sendAction(#selector(CodeEditWindowController.closeActiveEditor(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.control, .shift, .command])

            Button("Close Window") {
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.shift, .command])

            Button("Close Workspace") {
                // TODO: Determine how this is different than the "Close Window" command and adjust accordingly
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.control, .option, .command])

            if let utilityAreaViewModel {
                Button("Close Terminal") {
                    utilityAreaViewModel.removeTerminals(utilityAreaViewModel.selectedTerminals)
                }
                .keyboardShortcut(.delete)
            }

            Divider()

            Button("Save") {
                NSApp.sendAction(#selector(CodeEditWindowController.saveDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("s")
        }
    }

    private func createNewFile() {
        guard let windowController = getCurrentCEWindowController() else { return }

        let fileManager = FileManager.default
        let workspaceName = windowController.workspace?.workspaceFileManager?.folderUrl.lastPathComponent

        var hashedWorkspaceName = (workspaceName ?? "no-workspace").md5()

        let tempStorageDir = CodeEditApp.applicationSupportURL
            .appendingPathComponent("workspaces/\(hashedWorkspaceName)", isDirectory: true)

        do {
            try createDirectoryIfNotExists(atPath: tempStorageDir.path)

            let probableNumber = try predictNextTempFileNumber(in: tempStorageDir)

            let filename = "untitled-\(probableNumber)"
            let tempFileURL = tempStorageDir.appending(path: filename)
            fileManager.createFile(atPath: tempFileURL.path(percentEncoded: false), contents: nil)
            print("Saving new file at: \(tempFileURL.path)")

            let file = CEWorkspaceFile(url: tempFileURL)
            windowController.workspace?.editorManager.openTab(item: file)
        } catch {
            print(error)
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "An error occurred: \(error.localizedDescription)."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func getCurrentCEWindowController() -> CodeEditWindowController? {
        return NSApp.keyWindow?.windowController as? CodeEditWindowController
    }

    /// Creates a directory at a given path if it's not present
    /// - Parameter path: The path where the directory should be created
    private func createDirectoryIfNotExists(atPath path: String) throws {
        let fileManager = FileManager.default

        var isDir: ObjCBool = true
        let directoryExists = fileManager.fileExists(atPath: path, isDirectory: &isDir)

        if !directoryExists {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }

    private func predictNextTempFileNumber(in tempStorageDir: URL) throws -> Int {
        let fileManager = FileManager.default

        let fileNumbers = try fileManager.contentsOfDirectory(atPath: tempStorageDir.path)
            .compactMap { return $0.split(separator: "-").last }
            .compactMap { Int($0) }
            .sorted()

        var probableNumber = fileNumbers.first ?? 1
        for number in fileNumbers {
            if probableNumber != number {
                break
            }
            probableNumber += 1
        }

        return probableNumber
    }

}
