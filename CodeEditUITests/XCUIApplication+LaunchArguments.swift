//
//  XCUIApplication+LaunchArguments.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/6/24.
//

import XCTest

extension XCUIApplication {
    func openTestWorkspace(root: URL) {
        launchArguments += ["--open", root.standardizedFileURL.path()]
    }
}
