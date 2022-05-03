//
//  FinderSync.swift
//  openInCodeEdit
//
//  Created by Wesley de Groot on 03/05/2022.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
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
        print("Open in code eidt..")
//        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()

//        let item = sender as! NSMenuItem
//        NSLog(
//            "OpenInCE sampleAction: menu item: %@, target = %@ items = ",
//            item.title as NSString,
//            target!.path as NSString
//        )

        var fileURLs = ""
        for obj in items! {
            NSLog("OpenInCE %@", obj.path as NSString)
            fileURLs.append(" \(obj.path)")
        }

        guard let url = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "austincondiff.CodeEdit"
        ) else { return }

        let path = "\(fileURLs)"
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [path]

        NSWorkspace.shared.openApplication(at: url,
                                           configuration: configuration,
                                           completionHandler: nil)
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
