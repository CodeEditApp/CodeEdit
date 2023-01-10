//
//  NSDocumentController+Swizzle.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 07/01/2023.
//

import AppKit
import UniformTypeIdentifiers

extension NSDocumentController {
    static var isFirstLaunch = true

    @objc func swizzled_beginOpenPanel(
        _ openPanel: NSOpenPanel,
        forTypes inTypes: [String]?,
        completionHandler: @escaping (Int) -> Void
    ) {
        // Bugfix that prevented opening folders
        if let inTypes, inTypes.contains(UTType.folder.identifier) {
            openPanel.canChooseDirectories = true
        }

        // Don't open the file selector view on launch
        // TODO: improve isFirstLaunch checking
        guard !Self.isFirstLaunch else {
            Self.isFirstLaunch = false
            completionHandler(NSApplication.ModalResponse.cancel.rawValue)
            return
        }

        self.swizzled_beginOpenPanel(openPanel, forTypes: inTypes, completionHandler: completionHandler)
    }

    static func swizzle() {
        let originalSelector = #selector (NSDocumentController.beginOpenPanel(_:forTypes:completionHandler:))
        let swizzledSelector = #selector (NSDocumentController.swizzled_beginOpenPanel(_:forTypes:completionHandler:))

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
