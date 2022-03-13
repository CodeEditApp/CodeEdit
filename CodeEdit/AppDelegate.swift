//
//  AppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI

class CodeEditApplication: NSApplication {

    let strongDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = strongDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        _ = CodeEditDocumentController.shared
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let appearanceString = UserDefaults.standard.string(forKey: Appearances.appearanceStorageKey) {
            Appearances(rawValue: appearanceString)?.applyAppearance()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
