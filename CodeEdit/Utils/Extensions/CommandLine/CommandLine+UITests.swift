//
//  CommandLine+UITests.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/7/24.
//

import Foundation
import AppKit

extension CommandLine {
    /// Checks for UI modifiers and sets up the application for any flags that have been passed.
    /// Should be called at the very end of the application launch cycle.
    static func useUITestModifiers() {
        if shouldSpeedUpAnimations {
            NSApp.windows.forEach { window in
                window.contentView?.layer?.speed = 2.0
            }
        }
    }
    
    /// Is the app in UI testing mode. Only enabled for debug builds.
    static var isUITest: Bool {
        #if DEBUG
        Self.arguments.contains("-UITest")
        #else
        false
        #endif
    }

    /// Should animations be sped up. Only enabled for debug builds.
    static var shouldSpeedUpAnimations: Bool {
        #if DEBUG
        Self.arguments.contains("-disableAnimations")
        #else
        false
        #endif
    }
}
