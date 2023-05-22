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

    public var filter: String = "" {
        didSet { workspaceFileManager?.onRefresh() }
    }

    var statusBarModel = StatusBarViewModel()
    var searchState: SearchState?
    var quickOpenViewModel: QuickOpenViewModel?
    var commandsPaletteState: CommandPaletteViewModel?
    var listenerModel: WorkspaceNotificationModel = .init()

    override init() {
        super.init()
    }

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
//        self.workspaceClient = try .default(
//            fileManager: .default,
//            folderURL: url,
//            ignoredFilesAndFolders: ignoredFilesAndDirectory
//        )
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
}
