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
import StatusBar
import TabBar

@objc(WorkspaceDocument)
final class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    var workspaceClient: WorkspaceClient?

    var extensionNavigatorData = ExtensionNavigatorData()

    @Published var sortFoldersOnTop: Bool = true
    @Published var selectionState: WorkspaceSelectionState = .init()
    @Published var fileItems: [WorkspaceClient.FileItem] = []

    var statusBarModel: StatusBarModel?
    var searchState: SearchState?
    var quickOpenState: QuickOpenState?
    private var cancellables = Set<AnyCancellable>()

    @Published var targets: [Target] = []

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    /// Opens new tab
    /// - Parameter item: any item which can be represented as a tab
    func openTab(item: TabBarItemRepresentable) {
        do {
            switch item.tabID {
            case .codeEditor:
                guard let file = item as? WorkspaceClient.FileItem else { return }
                try self.openFile(item: file)
            case .extensionInstallation:
                guard let plugin = item as? Plugin else { return }
                self.openExtension(item: plugin)
            }

            if !selectionState.openedTabs.contains(item.tabID) {
                selectionState.openedTabs.append(item.tabID)
            }

            if selectionState.selectedId != item.tabID {
                selectionState.selectedId = item.tabID
            }
        } catch let err {
            Swift.print(err)
        }
    }

    private func openFile(item: WorkspaceClient.FileItem) throws {
        let codeFile = try CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: "public.source-code"
        )

        if !selectionState.openFileItems.contains(item) {
            selectionState.openFileItems.append(item)

            selectionState.openedCodeFiles[item] = codeFile
        }
        Swift.print("Opening file for item: ", item.url)
    }

    private func openExtension(item: Plugin) {
        if !selectionState.openedExtensions.contains(item) {
            selectionState.openedExtensions.append(item)
        }
    }

    /// Closes single tab
    /// - Parameter id: tab bar item's identifier to be closed
    func closeTab(item id: TabBarItemID) {
        guard let idx = selectionState.openedTabs.firstIndex(of: id) else { return }
        let closedID = selectionState.openedTabs.remove(at: idx)
        guard closedID == id else { return }

        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id) as? WorkspaceClient.FileItem else { return }
            closeFileTab(item: item)
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id) as? Plugin else { return }
            closeExtensionTab(item: item)
        }

        if selectionState.openedTabs.isEmpty {
            selectionState.selectedId = nil
        } else if selectionState.selectedId == closedID {
            // If the closed item is the selected one, then select another tab.
            if idx == 0 {
                selectionState.selectedId = selectionState.openedTabs.first
            } else {
                selectionState.selectedId = selectionState.openedTabs[idx - 1]
            }
        } else {
            // If the closed item is not the selected one, then do nothing.
        }
    }

    /// Closes collection of tab bar items
    /// - Parameter items: items to be closed
    func closeTabs<Items>(items: Items) where Items: Collection, Items.Element == TabBarItemID {
        // TODO: Could potentially be optimized
        for item in items {
            closeTab(item: item)
        }
    }

    /// Closes tabs according to predicator
    /// - Parameter predicate: predicator which returns whether tab should be closed based on its identifier
    func closeTab(where predicate: (TabBarItemID) -> Bool) {
        closeTabs(items: selectionState.openedTabs.filter(predicate))
    }

    /// Closes tabs after specified identifier
    /// - Parameter id: identifier after which tabs will be closed
    func closeTabs(after id: TabBarItemID) {
        guard let startIdx = selectionState.openFileItems.firstIndex(where: { $0.tabID == id }) else {
            assert(false, "Expected file item to be present in openFileItems")
            return
        }

        let range = selectionState.openedTabs[(startIdx+1)...]
        closeTabs(items: range)
    }

    private func closeFileTab(item: WorkspaceClient.FileItem) {
        defer {
            let file = selectionState.openedCodeFiles.removeValue(forKey: item)
            file?.save(self)
        }

        guard let idx = selectionState.openFileItems.firstIndex(of: item) else { return }
        selectionState.openFileItems.remove(at: idx)
    }

    private func closeExtensionTab(item: Plugin) {
        guard let idx = selectionState.openedExtensions.firstIndex(of: item) else { return }
        selectionState.openedExtensions.remove(at: idx)
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

    private func initWorkspaceState(_ url: URL) throws {
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        self.searchState = .init(self)
        self.quickOpenState = .init(fileURL: url)
        self.statusBarModel = .init(shellClient: Current.shellClient, workspaceURL: url)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        try initWorkspaceState(url)

        // Initialize Workspace
        do {
            if let projectDir = fileURL?.appendingPathComponent(".codeedit", isDirectory: true),
               FileManager.default.fileExists(atPath: projectDir.path) {
                let selectionStateFile = projectDir.appendingPathComponent("selection.json", isDirectory: false)

                if FileManager.default.fileExists(atPath: selectionStateFile.path) {
                    let state = try JSONDecoder().decode(WorkspaceSelectionState.self,
                                                         from: Data(contentsOf: selectionStateFile))
                    state.openedTabs
                        .compactMap { tab in
                            switch tab {
                            case .codeEditor(let path):
                                return try? workspaceClient?.getFileItem(path)
                            case .extensionInstallation:
                                return state.openedExtensions.first { plugin in
                                    plugin.tabID == tab
                                }
                            }
                        }
                        .forEach { item in
                        self.openTab(item: item)
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
