//
//  WorkspaceDocument.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation
import AppKit
import SwiftUI
import WorkspaceClient
import Combine
import CodeFile

@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    @Published var workspaceClient: WorkspaceClient?
    @Published var selectedId: String?
    @Published var openFileItems: [WorkspaceClient.FileItem] = []
	@Published var sortFoldersOnTop: Bool = true
    @Published var fileItems: [WorkspaceClient.FileItem] = []

    var openedCodeFiles: [WorkspaceClient.FileItem: CodeFileDocument] = [:]
	var folderURL: URL?
    private var cancellables = Set<AnyCancellable>()

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func closeFileTab(item: WorkspaceClient.FileItem) {
        defer {
            let file = openedCodeFiles.removeValue(forKey: item)
            file?.save(self)
        }

        guard let idx = openFileItems.firstIndex(of: item) else { return }
        let closedFileItem = openFileItems.remove(at: idx)
        guard closedFileItem.id == selectedId else { return }

        if openFileItems.isEmpty {
            selectedId = nil
            self.windowControllers.first?.document = self
        } else if idx == 0 {
            selectedId = openFileItems.first?.id
        } else {
            selectedId = openFileItems[idx - 1].id
        }
    }

    func openFile(item: WorkspaceClient.FileItem) {
        do {
            let codeFile = try CodeFileDocument(
                for: item.url,
                withContentsOf: item.url,
                ofType: "public.source-code"
            )

            if !openFileItems.contains(item) {
                openFileItems.append(item)

                openedCodeFiles[item] = codeFile
            }
            selectedId = item.id

            self.windowControllers.first?.window?.subtitle = item.url.lastPathComponent
        } catch let err {
            Swift.print(err)
        }
    }

    private let ignoredFilesAndDirectory = [
        ".DS_Store"
    ]

    override class var autosavesInPlace: Bool {
        return false
    }
    
    override var isDocumentEdited: Bool {
        return false
    }

    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.toolbar = NSToolbar()
        window.toolbarStyle = .unifiedCompact
        window.titlebarSeparatorStyle = .line
        window.toolbar?.displayMode = .iconOnly
        window.toolbar?.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
        let windowController = CodeEditWindowController(window: window)
        windowController.workspace = self
        let contentView = WorkspaceView(windowController: windowController, workspace: self)
        window.contentView = NSHostingView(rootView: contentView)
        self.addWindowController(windowController)
    }

    override func read(from url: URL, ofType typeName: String) throws {
		self.folderURL = url
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        workspaceClient?
            .getFiles
            .sink { [weak self] files in
                guard let self = self else { return }

                guard !self.fileItems.isEmpty else {
                    self.fileItems = files
                    return
                }

                // Instead of rebuilding the array we want to
                // calculate the difference between the last iteration
                // and now. If the index of the file exists in the array
                // it means we need to remove the element, otherwise we need to append
                // it.
                let diff = files.difference(from: self.fileItems)
                diff.forEach { newFile in
                    if let index = self.fileItems.firstIndex(of: newFile) {
                        self.fileItems.remove(at: index)
                    } else {
                        self.fileItems.append(newFile)
                    }
                }
            }
            .store(in: &cancellables)
    }

    override func write(to url: URL, ofType typeName: String) throws {}
    
    override func close() {
        selectedId = nil
        openFileItems.forEach { item in
            do {
                try openedCodeFiles[item]?.write(to: item.url, ofType: "public.source-code")
            } catch {}
        }
        super.close()
    }
}
