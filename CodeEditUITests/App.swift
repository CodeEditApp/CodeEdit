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

    // Launches CodeEdit in a new directory and returns the directory path.
    static func launchWithTempDir() throws -> (XCUIApplication, String) {
        let tempDirURL = try tempProjectPath()
        let application = XCUIApplication()
        application.launchArguments = ["-ApplePersistenceIgnoreState", "YES", "--open", tempDirURL]
        application.launch()
        return (application, tempDirURL)
    }

    // Launches CodeEdit with an app-writable directory that CodeEdit creates before opening.
    static func launchWithAppWritableTempDir() -> (XCUIApplication, String) {
        let tempDirID = appWritableTempProjectID()
        let application = XCUIApplication()
        application.launchArguments = [
            "-ApplePersistenceIgnoreState",
            "YES",
            "--codeedit-uitest-open-temp-workspace",
            tempDirID
        ]
        application.launch()
        return (application, appWritableTempProjectPath(id: tempDirID))
    }

    static func launch() -> XCUIApplication {
        let application = XCUIApplication()
        application.launchArguments = ["-ApplePersistenceIgnoreState", "YES"]
        application.launch()
        return application
    }
}
