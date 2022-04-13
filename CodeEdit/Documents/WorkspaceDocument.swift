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
import QuickOpen
import CodeEditKit
import ExtensionsStore

@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    var workspaceClient: WorkspaceClient?

    var extensionNavigatorData = ExtensionNavigatorData()

    @Published var sortFoldersOnTop: Bool = true
    @Published var selectionState: WorkspaceSelectionState = .init()

    var searchState: SearchState?
    var quickOpenState: QuickOpenState?
    private var cancellables = Set<AnyCancellable>()

    @Published var targets: [Target] = []

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
            if selectionState.selectedId != item.id {
                selectionState.selectedId = item.id
            }
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
        window.minSize = .init(width: 1000, height: 600)
        let windowController = CodeEditWindowController(
            window: window,
            workspace: self
        )
        self.addWindowController(windowController)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        self.searchState = .init(self)
        self.quickOpenState = .init(fileURL: url)

        // Initialize Workspace
        do {
            if let projectDir = fileURL?.appendingPathComponent(".codeedit", isDirectory: true),
               FileManager.default.fileExists(atPath: projectDir.path) {
                let selectionStateFile = projectDir.appendingPathComponent("selection.json", isDirectory: false)

                if FileManager.default.fileExists(atPath: selectionStateFile.path) {
                    let state = try JSONDecoder().decode(WorkspaceSelectionState.self,
                                                         from: Data(contentsOf: selectionStateFile))
                    self.selectionState.fileItems = state.fileItems
                    state.openFileItems
                        .compactMap { try? workspaceClient?.getFileItem($0.id) }
                        .forEach { item in
                        self.openFile(item: item)
                    }
                    self.selectionState.selectedId = state.selectedId
                }
            }
        } catch {
            Swift.print(".codeedit/selection.json is not found")
        }

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

        // initialize extensions
        do {
            try ExtensionsManager.shared?.load { extensionID in
                return CodeEditAPI(extensionId: extensionID, workspace: self)
            }
        } catch let error {
            Swift.print(error)
        }
    }

    override func write(to url: URL, ofType typeName: String) throws {}

    override func close() {
        if let projectDir = fileURL?.appendingPathComponent(".codeedit", isDirectory: true) {
            do {
                if !FileManager.default.fileExists(atPath: projectDir.path) {
                    do {
                        try FileManager.default.createDirectory(at: projectDir,
                                                                withIntermediateDirectories: false,
                                                                attributes: [:])
                    }
                }
                let selectionStateFile = projectDir.appendingPathComponent("selection.json", isDirectory: false)
                let data = try JSONEncoder().encode(selectionState)
                if FileManager.default.fileExists(atPath: selectionStateFile.path) {
                    do {
                        try FileManager.default.removeItem(at: selectionStateFile)
                    }
                }
                try data.write(to: selectionStateFile)
            } catch let error {
                Swift.print(error)
            }
        }

        selectionState.selectedId = nil
        selectionState.openFileItems.forEach { item in
            do {
                try selectionState.openedCodeFiles[item]?.write(to: item.url, ofType: "public.source-code")
                selectionState.openedCodeFiles[item]?.close()
            } catch {}
        }
        selectionState.openedCodeFiles.removeAll()

        if let url = self.fileURL {
            ExtensionsManager.shared?.close(url: url)
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

// MARK: - Selection

struct WorkspaceSelectionState: Codable {

    var selectedId: String?
    var openFileItems: [WorkspaceClient.FileItem] = []
    var fileItems: [WorkspaceClient.FileItem] = []

    var selected: WorkspaceClient.FileItem? {
        guard let selectedId = selectedId else { return nil }
        return fileItems.first(where: { $0.id == selectedId })
    }
    var openedCodeFiles: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    enum CodingKeys: String, CodingKey {
        case selectedId, openFileItems
    }

    init() {
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedId = try container.decode(String?.self, forKey: .selectedId)
        openFileItems = try container.decode([WorkspaceClient.FileItem].self, forKey: .openFileItems)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedId, forKey: .selectedId)
        try container.encode(openFileItems, forKey: .openFileItems)
    }
}

// MARK: - Extensions
extension WorkspaceDocument {
    func target(didAdd target: Target) {
        self.targets.append(target)
    }
    func target(didRemove target: Target) {
        self.targets.removeAll { $0.id == target.id }
    }
    func targetDidClear() {
        self.targets.removeAll()
    }
}
