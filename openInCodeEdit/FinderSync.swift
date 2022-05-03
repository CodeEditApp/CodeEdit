//
//  FinderSync.swift
//  openInCodeEdit
//
//  Created by Wesley de Groot on 03/05/2022.
//

import Cocoa
import FinderSync

class CEOpenWith: FIFinderSync {
    override init() {
        super.init()
        // Add finder sync
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }

    /// Open in CodeEdit (menu) action
    /// - Parameter sender: sender
    @objc func openInCodeEditAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            return
        }

        // Make values compatible to ArrayLiteralElement
        var fileURLs: [URL] = []

        for obj in items {
            NSLog("OpenInCE Append urls %@", obj.path as NSString)
            fileURLs.append(.init(string: "\(obj.path)")!)
        }

        guard let codeEdit = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "austincondiff.CodeEdit"
        ) else { return }

        NSLog("CEOpener:\n CE Path: %@\n Files to open: %@",
              codeEdit.path as NSString,
              fileURLs
        )

        let path = "\(fileURLs)"
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [path]

        // The "configuration" will be ignored if sandboxed,
        // but we cannot run a extension without sandbox.
//        NSWorkspace.shared.openApplication(at: codeEdit,
//                                           configuration: configuration,
//                                           completionHandler: nil)

        // without using file://
        // The application “CodeEdit.app” cannot open the specified document or URL.
        // if using file://[filename]
        // The application “openInCodeEdit” does not have permission to open “CODE_OF_CONDUCT.md.”
        NSWorkspace.shared.open(fileURLs,
                                withApplicationAt: codeEdit,
                                configuration: NSWorkspace.OpenConfiguration())

        
    }

    // MARK: - Menu and toolbar item support
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        let menuItem = NSMenuItem(title: "Open in CodeEdit",
                                  action: #selector(openInCodeEditAction(_:)),
                                  keyEquivalent: ""
        )
        menuItem.image = NSImage(named: NSImage.cautionName)!
        menu.addItem(menuItem)

        return menu
    }
}
