//
//  XCUIApplication+LaunchArguments.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/6/24.
//

import XCTest

extension XCUIApplication {
    func enableTestMode() {
        launchArguments += ["-UITest"]
    }

    func speedUpAnimations() {
        launchArguments += ["-disableAnimations"]
    }

    func openTestWorkspace(root: URL) {
        print(root.standardizedFileURL.path())
        launchArguments += ["--open", root.standardizedFileURL.path()]
    }
}
