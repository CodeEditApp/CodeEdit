//
//  UnitTests.swift
//  CodeEditModules/WelcomeModuleTests
//
//  Created by Ziyuan Zhao on 2022/3/19.
//

@testable import CodeEdit
import Foundation
import SwiftUI
import XCTest

final class WelcomeModuleUnitTests: XCTestCase {

    func testRecentProjectItemLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path"))
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .light)
    }

    func testRecentProjectItemDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path"))
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .dark)
    }

    func testRecentJSFileLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path/test.js"))
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .light)
    }

    func testRecentJSFileDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path/test.js"))
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .dark)
    }

    func testWelcomeActionViewLightSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            action: { }
        )
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .light)
    }

    func testWelcomeActionViewDarkSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            action: { }
        )
        snapshot(view: view, size: .init(width: 300, height: 60), appearance: .dark)
    }
}
