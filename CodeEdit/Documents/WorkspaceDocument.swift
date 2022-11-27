//
//  WorkspaceDocument.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation
import AppKit
import SwiftUI
import Combine
import CodeEditKit

// swiftlint:disable type_body_length
// swiftlint:disable file_length
@objc(WorkspaceDocument) final class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    var workspaceClient: WorkspaceClient?

    var extensionNavigatorData = ExtensionNavigatorData()

    @Published var sortFoldersOnTop: Bool = true
    @Published var selectionState: WorkspaceSelectionState = .init()
    @Published var fileItems: [WorkspaceClient.FileItem] = []

    var statusBarModel: StatusBarViewModel?
    var searchState: SearchState?
    var quickOpenViewModel: QuickOpenViewModel?
    var commandsPaletteState: CommandPaletteViewModel?
    var listenerModel: WorkspaceNotificationModel = .init()
    private var cancellables = Set<AnyCancellable>()

    @Published var targets: [Target] = []

    deinit {
        cancellables.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Open Tabs
    /// Opens new tab
    /// - Parameter item: any item which can be represented as a tab
    func openTab(item: TabBarItemRepresentable) {
        do {
            updateNewlyOpenedTabs(item: item)
            if selectionState.selectedId != item.tabID {
                selectionState.selectedId = item.tabID
            }
            switch item.tabID {
            case .codeEditor:
                guard let file = item as? WorkspaceClient.FileItem else { return }
                try self.openFile(item: file)
            case .extensionInstallation:
                guard let plugin = item as? Plugin else { return }
                self.openExtension(item: plugin)
            }

        } catch let err {
            Swift.print(err)
        }
    }

    /// Updates the opened tabs and temporary tab.
    /// - Parameter item: The item to use to update the tab state.
    private func updateNewlyOpenedTabs(item: TabBarItemRepresentable) {
        if !selectionState.openedTabs.contains(item.tabID) {
            // If this isn't opened then we do the temp tab functionality

            // But, if there is already a temporary tab, close it first
            if selectionState.temporaryTab != nil {
                if let index = selectionState.openedTabs.firstIndex(of: selectionState.temporaryTab!) {
                    closeTemporaryTab()
                    selectionState.openedTabs[index] = item.tabID
                } else {
                    selectionState.openedTabs.append(item.tabID)
                }
            } else {
                selectionState.openedTabs.append(item.tabID)
            }

            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = item.tabID
        }
    }

    private func openFile(item: WorkspaceClient.FileItem) throws {
        guard !selectionState.openFileItems.contains(item) else {
            return
        }
        selectionState.openFileItems.append(item)

        let contentType = try item.url.resourceValues(forKeys: [.contentTypeKey]).contentType
        let codeFile = try CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: contentType?.identifier ?? ""
        )
        selectionState.openedCodeFiles[item] = codeFile
        CodeEditDocumentController.shared.addDocument(codeFile)
        Swift.print("Opening file for item: ", item.url)
    }

    private func openExtension(item: Plugin) {
        if !selectionState.openedExtensions.contains(item) {
            selectionState.openedExtensions.append(item)
        }
    }

    // MARK: Close Tabs

    /// Closes single tab
    /// - Parameter id: tab bar item's identifier to be closed
    func closeTab(item id: TabBarItemID) {
        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id) as? WorkspaceClient.FileItem else { return }
            closeFileTab(item: item)
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id) as? Plugin else { return }
            closeExtensionTab(item: item)
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

    /// Closes an open temporary tab,  does not save the temporary tab's file.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeTemporaryTab() {
        guard let id = selectionState.temporaryTab else { return }

        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id)
                    as? WorkspaceClient.FileItem else { return }
            selectionState.openedCodeFiles.removeValue(forKey: item)
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id)
                    as? Plugin else { return }
            closeExtensionTab(item: item)
        }

        guard let openFileItemIdx = selectionState
            .openFileItems
            .firstIndex(where: { $0.tabID == id }) else { return }
        selectionState.openFileItems.remove(at: openFileItemIdx)
    }

    /// Closes an open tab, save text files only.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeFileTab(item: WorkspaceClient.FileItem) {
        guard let file = selectionState.openedCodeFiles[item],
              let openFileItemIndex = selectionState.openFileItems.firstIndex(of: item)
        else {
            return
        }
        if file.isDocumentEdited {
            let shouldClose = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            shouldClose.initialize(to: true)
            defer {
                _ = shouldClose.move()
                shouldClose.deallocate()
            }
            file.canClose(
                withDelegate: self,
                shouldClose: #selector(document(_:shouldClose:contextInfo:)),
                contextInfo: shouldClose
            )
            guard shouldClose.pointee else {
                return
            }
        }
        selectionState.openedCodeFiles.removeValue(forKey: item)
        selectionState.openFileItems.remove(at: openFileItemIndex)
        removeTab(id: item.tabID)
    }

    private func closeExtensionTab(item: Plugin) {
        guard let idx = selectionState.openedExtensions.firstIndex(of: item) else { return }
        selectionState.openedExtensions.remove(at: idx)

        removeTab(id: item.tabID)
    }

    /// Makes the temporary tab permanent when a file save or edit happens.
    @objc func convertTemporaryTab() {
        if selectionState.selectedId == selectionState.temporaryTab &&
            selectionState.temporaryTab != nil {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }
    }

    /// Removes the tab from `openedTabs`.
    /// - Parameter id: The id of `TabBarItemID` which will be removed.
    private func removeTab(id: TabBarItemID) {
        if id == selectionState.temporaryTab {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }

        guard let idx = selectionState.openedTabs.firstIndex(of: id) else { return }
        let closedID = selectionState.openedTabs.remove(at: idx)
        guard closedID == id else { return }

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

    // MARK: NSDocument

    private let ignoredFilesAndDirectory = [
        ".DS_Store"
    ]

    override class var autosavesInPlace: Bool {
        false
    }

    override var isDocumentEdited: Bool {
        false
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

    // MARK: Set Up Workspace

    private func initWorkspaceState(_ url: URL) throws {
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        self.searchState = .init(self)
        self.quickOpenViewModel = .init(fileURL: url)
        self.commandsPaletteState = .init()
        self.statusBarModel = .init(workspaceURL: url)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(convertTemporaryTab),
                                               name: NSNotification.Name("CodeEditor.didBeginEditing"),
                                               object: nil)
    }

    /// Retrieves selection state from UserDefaults using SHA256 hash of project  path as key
    /// - Throws: `DecodingError.dataCorrupted` error if retrived data from UserDefaults is not decodable
    /// - Returns: retrived state from UserDefaults or default state if not found
    private func readSelectionState() throws -> WorkspaceSelectionState {
        guard let path = fileURL?.path,
              let data = UserDefaults.standard.value(forKey: path.sha256()) as? Data  else { return selectionState }
        let state = try PropertyListDecoder().decode(WorkspaceSelectionState.self, from: data)
        return state
    }

    override func read(from url: URL, ofType typeName: String) throws {
        try initWorkspaceState(url)

        // Initialize Workspace
        do {
            selectionState = try readSelectionState()
        } catch {
            Swift.print("couldn't retrieve selection state from user defaults")
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
        ExtensionManager.shared.loadExtensions { extensionID in
            CodeEditAPI(extensionId: extensionID, workspace: self)
        }
//        do {
//            try ExtensionsManager.shared?.load { extensionID in
//                CodeEditAPI(extensionId: extensionID, workspace: self)
//            }
//        } catch let error {
//            Swift.print(error)
//        }
    }

    override func write(to url: URL, ofType typeName: String) throws {}

    // MARK: Close Workspace

    /// Saves selection state to UserDefaults using SHA256 hash of project  path as key
    /// - Throws: `EncodingError.invalidValue` error if sellection state is not encodable
    private func saveSelectionState() throws {
        guard let path = fileURL?.path else { return }
        let hash = path.sha256()
        let data = try PropertyListEncoder().encode(selectionState)
        UserDefaults.standard.set(data, forKey: hash)
    }

    override func close() {
        do {
            try saveSelectionState()
        } catch {
            Swift.print("couldn't save selection state from user defaults")
        }

        selectionState.selectedId = nil
        selectionState.openedCodeFiles.removeAll()

        if let url = self.fileURL {
            ExtensionsManager.shared?.close(url: url)
        }

        super.close()
    }

    /// Determines the windows should be closed.
    ///
    /// This method iterates all edited documents If there are any edited documents.
    ///
    /// A panel giving the user the choice of canceling, discarding changes, or saving is presented while iteration.
    ///
    /// If the user chooses cancel on the panel, iteration is broken.
    ///
    /// In the last step, `shouldCloseSelector` is called with true if all documents are clean, otherwise false
    ///
    /// - Parameters:
    ///   - windowController: The windowController may be closed.
    ///   - delegate: The object which is a target of `shouldCloseSelector`.
    ///   - shouldClose: The callback which receives result of this method.
    ///   - contextInfo: The additional info which is not used in this method.
    override func shouldCloseWindowController(
        _ windowController: NSWindowController,
        delegate: Any?,
        shouldClose shouldCloseSelector: Selector?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        guard let object = (delegate as? NSObject),
              let shouldCloseSelector = shouldCloseSelector,
              let contextInfo = contextInfo
        else {
            super.shouldCloseWindowController(
                windowController,
                delegate: delegate,
                shouldClose: shouldCloseSelector,
                contextInfo: contextInfo
            )
            return
        }
        // Save unsaved changes before closing
        let editedCodeFiles = selectionState.openedCodeFiles.values.filter { $0.isDocumentEdited }
        for editedCodeFile in editedCodeFiles {
            let shouldClose = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            shouldClose.initialize(to: true)
            defer {
                _ = shouldClose.move()
                shouldClose.deallocate()
            }
            // Present a panel giving the user the choice of canceling, discarding changes, or saving.
            editedCodeFile.canClose(
                withDelegate: self,
                shouldClose: #selector(document(_:shouldClose:contextInfo:)),
                contextInfo: shouldClose
            )
            // pointee becomes false when user select cancel
            guard shouldClose.pointee else {
                break
            }
        }
        // Invoke shouldCloseSelector at delegate
        let implementation = object.method(for: shouldCloseSelector)
        let function = unsafeBitCast(
            implementation,
            to: (@convention(c)(Any, Selector, Any, Bool, UnsafeMutableRawPointer?) -> Void).self
        )
        let areAllOpenedCodeFilesClean = selectionState.openedCodeFiles.values.allSatisfy { !$0.isDocumentEdited }
        function(object, shouldCloseSelector, self, areAllOpenedCodeFilesClean, contextInfo)
    }

    // MARK: NSDocument delegate

    /// Receives result of `canClose` and then, set `shouldClose` to `contextInfo`'s `pointee`.
    ///
    /// - Parameters:
    ///   - document: The document may be closed.
    ///   - shouldClose: The result of user selection.
    ///      `shouldClose` becomes false if the user selects cancel, otherwise true.
    ///   - contextInfo: The additional info which will be set `shouldClose`.
    ///       `contextInfo` must be `UnsafeMutablePointer<Bool>`.
    @objc private func document(
        _ document: NSDocument,
        shouldClose: Bool,
        contextInfo: UnsafeMutableRawPointer
    ) {
        let opaquePtr = OpaquePointer(contextInfo)
        let mutablePointer = UnsafeMutablePointer<Bool>(opaquePtr)
        mutablePointer.pointee = shouldClose
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
