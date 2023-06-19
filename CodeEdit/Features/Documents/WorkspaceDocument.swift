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

@objc(WorkspaceDocument) final class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {

    @Published var sortFoldersOnTop: Bool = true

    var workspaceFileManager: CEWorkspaceFileManager?

    var tabManager = TabManager()

    var workspaceState: [String: Any] {
        get {
            let key = "workspaceState-\(self.fileURL?.absoluteString ?? "")"
            return UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
        }
        set {
            let key = "workspaceState-\(self.fileURL?.absoluteString ?? "")"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    var debugAreaModel = DebugAreaViewModel()
    var searchState: SearchState?
    var quickOpenViewModel: QuickOpenViewModel?
    var commandsPaletteState: CommandPaletteViewModel?
    var listenerModel: WorkspaceNotificationModel = .init()

    private var cancellables = Set<AnyCancellable>()
    private let openTabsStateName: String = "\(String(describing: WorkspaceDocument.self))-OpenTabs"
    private let activeTabStateName: String = "\(String(describing: WorkspaceDocument.self))-ActiveTab"
    private var openedTabsFromState = false

    deinit {
        cancellables.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }

    func getFromWorkspaceState(key: String) -> Any? {
        return workspaceState[key]
    }

    func addToWorkspaceState(key: String, value: Any) {
        workspaceState.updateValue(value, forKey: key)
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

        windowController.shouldCascadeWindows = true
        windowController.window?.setFrameAutosaveName(self.fileURL?.absoluteString ?? "Untitled")
        self.addWindowController(windowController)

        // TODO: Fix restoration
//        var activeTabID: TabBarItemID?
//        var activeTabInState = self.getFromWorkspaceState(key: activeTabStateName) as? String ?? ""
//        var openTabsInState = self.getFromWorkspaceState(key: openTabsStateName) as? [String] ?? []
//        for openTab in openTabsInState {
//            let tabUrl = URL(string: openTab)!
//            if FileManager.default.fileExists(atPath: tabUrl.path) {
//                let item = WorkspaceClient.FileItem(url: tabUrl)
//                self.tabManager.openTab(item: item)
//                self.convertTemporaryTab()
//                if activeTabInState == openTab {
//                    activeTabID = item.tabID
//                }
//            }
//        }

        self.openedTabsFromState = true
    }

    // MARK: Set Up Workspace

    private func initWorkspaceState(_ url: URL) throws {
//        self.fileManager = CEWorkspaceFileActor(root: url, ignoring: Set(ignoredFilesAndDirectory.map { .name($0) }))
        self.workspaceFileManager = .init(
            folderUrl: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
        self.searchState = .init(self)
        self.quickOpenViewModel = .init(fileURL: url)
        self.commandsPaletteState = .init()
    }

    override func read(from url: URL, ofType typeName: String) throws {
        try initWorkspaceState(url)
        buildFileTree(root: url)
    }

    override func write(to url: URL, ofType typeName: String) throws {}

    // MARK: Close Workspace

    override func close() {
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
        let editedCodeFiles = tabManager.tabGroups
            .gatherOpenFiles()
            .compactMap(\.fileDocument)
            .filter(\.isDocumentEdited)

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
        let areAllOpenedCodeFilesClean = tabManager.tabGroups.gatherOpenFiles()
            .compactMap(\.fileDocument)
            .allSatisfy { !$0.isDocumentEdited }
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
    @objc func document(
        _ document: NSDocument,
        shouldClose: Bool,
        contextInfo: UnsafeMutableRawPointer
    ) {
        let opaquePtr = OpaquePointer(contextInfo)
        let mutablePointer = UnsafeMutablePointer<Bool>(opaquePtr)
        mutablePointer.pointee = shouldClose
    }

    enum FileManagerError: Error {
        case rootFileEnumeration
    }

    @Published
    var fileTree: (any ResourceData)?

    var ignoredResources: Set<Resource.Ignored> = [
        .file(name: ".DS_Store")
    ]

    private var buildFileTreeTask: Task<Void, Error>?

    override func presentedSubitem(at oldURL: URL, didMoveTo newURL: URL) {
        guard let basePath = fileURL?.path() else { return }

        // We need to apply this weird trick as oldURL and newURL might differ in URL formatting.
        let oldPath = oldURL.path().split(separator: basePath).last ?? ""
        let newPath = newURL.path().split(separator: basePath).last ?? ""

        // The old resource location
        let oldPathComponents = oldPath.split(separator: "/").map { String($0) }

        // The folder where the resource will be placed in
        let newPathComponents = newPath.split(separator: "/").dropLast().map { String($0) }

        // Get resource and parent folder
        guard let resolved = fileTree?.resolveItem(components: oldPathComponents), let parentFolder = resolved.parentFolder else {
            showError(FileError.couldNotResolveFile)
            return
        }

        // Get new parent folder
        guard let newParentFolder = fileTree?.resolveItem(components: newPathComponents) as? Folder else {
            showError(FileError.couldNotResolveFile)
            return
        }

        // Move resource from old to new folder
        parentFolder.removeChild(resolved)
        newParentFolder.children.append(resolved)
        resolved.parentFolder = newParentFolder

        do {
            if let newName = try newURL.resourceValues(forKeys: [.nameKey]).name {
                resolved.name = newName
            } else {
                showError(FileError.noFileName)
            }
        } catch {
            showError(error)
        }
    }

    enum FileError: Error {
        case couldNotResolveFile
        case noFileName
    }

    @MainActor
    func showError(_ error: any Error) {
        let alert = NSAlert()
        alert.informativeText = error.localizedDescription
        alert.messageText = "Error"
        alert.runModal()
    }

    func buildFileTree(root: URL) {
        buildFileTreeTask = Task {
            fileTree = try await buildingFileTree(root: root, ignoring: ignoredResources)
        }
    }

    nonisolated func buildingFileTree(root: URL, ignoring: Set<Resource.Ignored>) async throws -> any ResourceData {
        let fileProperties: Set<URLResourceKey> = [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey, .nameKey, .fileResourceIdentifierKey]
        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: Array(fileProperties))

        guard let enumerator else { throw FileManagerError.rootFileEnumeration }

        let rootFolder = Folder(url: root, name: root.lastPathComponent)

        var folderStack = [rootFolder]
        var currentLevel = 1
        var possibleNewFolder: Folder?

        for case let url as URL in enumerator {
            guard !Task.isCancelled else { throw CancellationError() }
            let properties = try url.resourceValues(forKeys: fileProperties)

            let name = properties.name!
            let isFile = properties.isRegularFile!
            let isFolder = properties.isDirectory!
            let isSymLink = properties.isSymbolicLink!

            let level = enumerator.level

            if level < currentLevel {
                folderStack.removeLast(currentLevel - level)
                currentLevel = level
            } else if level > currentLevel, let newCurrent = possibleNewFolder {
                folderStack.append(newCurrent)
                possibleNewFolder = nil
                currentLevel += 1
            }

            guard !ignoring.contains(.file(name: name)) && !ignoring.contains(.url(url)) else {
//                enumerator.skipDescendants()
                continue
            }

            let resource: any ResourceData
            let currentFolder = folderStack.last!

            if isFile {
                resource = File(url: url, name: name)
            } else if isFolder {
                let newFolder = Folder(url: url, name: name)
                resource = newFolder
                possibleNewFolder = newFolder
            } else if isSymLink {
                resource = SymLink(url: url, name: name)
            } else {
                continue
            }

            resource.parentFolder = currentFolder
            currentFolder.children.append(resource)
        }

        return rootFolder
    }
}
