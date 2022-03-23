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
import Search

@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    var workspaceClient: WorkspaceClient?

    @Published var sortFoldersOnTop: Bool = true
    @Published var selectionState: SelectionState = .init()

    var searchState: SearchState?
    var quickOpenState: QuickOpenState?
    private var cancellables = Set<AnyCancellable>()

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func closeFileTab(item: WorkspaceClient.FileItem) {
        defer {
            let file = selectionState.openedCodeFiles.removeValue(forKey: item)
            file?.save(self)
        }

        guard let idx = selectionState.openFileItems.firstIndex(of: item) else { return }
        let closedFileItem = selectionState.openFileItems.remove(at: idx)
        guard closedFileItem.id == item.id else { return }

        if selectionState.openFileItems.isEmpty {
            selectionState.selectedId = nil
        } else if idx == 0 {
            selectionState.selectedId = selectionState.openFileItems.first?.id
        } else {
            selectionState.selectedId = selectionState.openFileItems[idx - 1].id
        }
    }
    func closeFileTabs<Items>(items: Items) where Items: Collection, Items.Element == WorkspaceClient.FileItem {
        // TODO: Could potentially be optimized
        for item in items {
            closeFileTab(item: item)
        }
    }

    func closeFileTab(where predicate: (WorkspaceClient.FileItem) -> Bool) {
        closeFileTabs(items: selectionState.openFileItems.filter(predicate))
    }

    func closeFileTabs(after item: WorkspaceClient.FileItem) {
        guard let startIdx = selectionState.openFileItems.firstIndex(where: { $0.id == item.id }) else {
            assert(false, "Expected file item to be present in openFileItems")
            return
        }

        let range = selectionState.openFileItems[(startIdx+1)...]
        closeFileTabs(items: range)
    }

    func openFile(item: WorkspaceClient.FileItem) {
        do {
            let codeFile = try CodeFileDocument(
                for: item.url,
                withContentsOf: item.url,
                ofType: "public.source-code"
            )

            if !selectionState.openFileItems.contains(item) {
                selectionState.openFileItems.append(item)

                selectionState.openedCodeFiles[item] = codeFile
            }
            selectionState.selectedId = item.id
            Swift.print("Opening file for item: ", item.url)
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
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        self.searchState = .init(self)
        self.quickOpenState = .init(self)
        workspaceClient?
            .getFiles
            .sink { [weak self] files in
                guard let self = self else { return }

                guard !self.selectionState.fileItems.isEmpty else {
                    self.selectionState.fileItems = files
                    return
                }

                // Instead of rebuilding the array we want to
                // calculate the difference between the last iteration
                // and now. If the index of the file exists in the array
                // it means we need to remove the element, otherwise we need to append
                // it.
                let diff = files.difference(from: self.selectionState.fileItems)
                diff.forEach { newFile in
                    if let index = self.selectionState.fileItems.firstIndex(of: newFile) {
                        self.selectionState.fileItems.remove(at: index)
                    } else {
                        self.selectionState.fileItems.append(newFile)
                    }
                }
            }
            .store(in: &cancellables)
    }

    override func write(to url: URL, ofType typeName: String) throws {}

    override func close() {
        selectionState.selectedId = nil
        selectionState.openFileItems.forEach { item in
            do {
                try selectionState.openedCodeFiles[item]?.write(to: item.url, ofType: "public.source-code")
            } catch {}
        }
        super.close()
    }
}

// MARK: - Search

extension WorkspaceDocument {
    class SearchState: ObservableObject {
        var workspace: WorkspaceDocument
        @Published var searchResult: [SearchResultModel] = []

        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
        }

        func search(_ text: String) {
            self.searchResult = []
            if let url = self.workspace.fileURL {
                let enumerator = FileManager.default.enumerator(at: url,
                                                                includingPropertiesForKeys: [
                                                                    .isRegularFileKey
                                                                ],
                                                                options: [
                                                                    .skipsHiddenFiles,
                                                                    .skipsPackageDescendants
                                                                ])
                if let filePaths = enumerator?.allObjects as? [URL] {
                    filePaths.map { url in
                        WorkspaceClient.FileItem(url: url, children: nil)
                    }.forEach { fileItem in
                        var fileAddedFlag = true
                        do {
                            let data = try Data(contentsOf: fileItem.url)
                            data.withUnsafeBytes {
                                $0.split(separator: UInt8(ascii: "\n"))
                                    .map { String(decoding: UnsafeRawBufferPointer(rebasing: $0), as: UTF8.self) }
                            }.enumerated().forEach { (index: Int, line: String) in
                                let noSpaceLine = line.trimmingCharacters(in: .whitespaces)
                                if noSpaceLine.contains(text) {
                                    if fileAddedFlag {
                                        searchResult.append(SearchResultModel(
                                            file: fileItem,
                                            lineNumber: nil,
                                            lineContent: nil,
                                            keywordRange: nil)
                                        )
                                        fileAddedFlag = false
                                    }
                                    noSpaceLine.ranges(of: text).forEach { range in
                                        searchResult.append(SearchResultModel(
                                            file: fileItem,
                                            lineNumber: index,
                                            lineContent: noSpaceLine,
                                            keywordRange: range)
                                        )
                                    }
                                }
                            }
                        } catch {}
                    }
                }
            }
        }
    }
}

// MARK: - Quick Open

extension WorkspaceDocument {

    class QuickOpenState: ObservableObject {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
        }

        var workspace: WorkspaceDocument

        @Published var openQuicklyQuery: String = ""
        @Published var openQuicklyFiles: [WorkspaceClient.FileItem] = []
        @Published var isShowingOpenQuicklyFiles: Bool = false

        func fetchOpenQuickly() {
            if openQuicklyQuery == "" {
                openQuicklyFiles = []
                self.isShowingOpenQuicklyFiles = !openQuicklyFiles.isEmpty
                return
            }

            DispatchQueue(label: "austincondiff.CodeEdit.quickOpen.searchFiles").async { [weak self] in
                if let self = self, let url = self.workspace.fileURL {
                    let enumerator = FileManager.default.enumerator(at: url,
                                                                    includingPropertiesForKeys: [
                                                                        .isRegularFileKey
                                                                    ],
                                                                    options: [
                                                                        .skipsHiddenFiles,
                                                                        .skipsPackageDescendants
                                                                    ])
                    if let filePaths = enumerator?.allObjects as? [URL] {
                        let files = filePaths.filter { url in
                            let state1 = url.lastPathComponent.lowercased().contains(self.openQuicklyQuery.lowercased())
                            do {
                                let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                                return state1 && (values.isRegularFile ?? false)
                            } catch {
                                return false
                            }
                        }.map { url in
                            WorkspaceClient.FileItem(url: url, children: nil)
                        }
                        DispatchQueue.main.async {
                            self.openQuicklyFiles = files
                            self.isShowingOpenQuicklyFiles = !self.openQuicklyFiles.isEmpty
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Selection

extension WorkspaceDocument {

    struct SelectionState {

        var selectedId: String?
        var openFileItems: [WorkspaceClient.FileItem] = []
        var fileItems: [WorkspaceClient.FileItem] = []

        var selected: WorkspaceClient.FileItem? {
            guard let selectedId = selectedId else { return nil }
            return fileItems.first(where: { $0.id == selectedId })
        }
        var openedCodeFiles: [WorkspaceClient.FileItem: CodeFileDocument] = [:]
    }

}
