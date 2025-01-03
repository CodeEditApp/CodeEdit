//
//  App.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/21/24.
//

import XCTest

enum App {
    static func launchWithCodeEditWorkspace() -> XCUIApplication {
        let application = XCUIApplication()
        application.launchArguments = ["-ApplePersistenceIgnoreState", "YES", "--open", projectPath()]
        application.launch()
        return application
    }

    // Launches CodeEdit in a new directory
    static func launchWithTempDir() throws -> XCUIApplication {
        let application = XCUIApplication()
        application.launchArguments = ["-ApplePersistenceIgnoreState", "YES", "--open", try tempProjectPath()]
        application.launch()
        return application
    }

    static func launch() -> XCUIApplication {
        let application = XCUIApplication()
        application.launchArguments = ["-ApplePersistenceIgnoreState", "YES"]
        application.launch()
        return application
    }
}
