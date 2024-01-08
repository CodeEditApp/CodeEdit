//
//  CommandLine+LaunchArguments.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/8/24.
//

import Foundation
import AppKit

extension CommandLine {
    /// Finds and opens files passed to the app via command line arguments.
    /// - Returns: If any files were opened by this method.
    static func openArgumentFiles() -> Bool {
        var needToHandleOpen = true

        // If no windows were reopened by NSQuitAlwaysKeepsWindows, do default behavior.
        // Non-WindowGroup SwiftUI Windows are still in NSApp.windows when they are closed,
        // So we need to think about those.
        if NSApp.windows.count > NSApp.openSwiftUIWindows {
            needToHandleOpen = false
        }

        for index in 0..<CommandLine.arguments.count {
            if CommandLine.arguments[index] == "--open" && (index + 1) < CommandLine.arguments.count {
                let path = CommandLine.arguments[index+1]
                let url = URL(fileURLWithPath: path)

                CodeEditDocumentController.shared.reopenDocument(
                    for: url,
                    withContentsOf: url,
                    display: true
                ) { document, _, _ in
                    document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                }

                needToHandleOpen = false
            }
        }

        return needToHandleOpen
    }
}
