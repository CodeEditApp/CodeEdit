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
        application.launchArguments = ["--open", projectPath()]
        application.launch()
        return application
    }

    static func launch() -> XCUIApplication {
        let application = XCUIApplication()
        application.launch()
        return application
    }
}
