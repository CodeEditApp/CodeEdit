//
//  UnitTests.swift
//  CodeEditModules/WelcomeModuleTests
//
//  Created by Ziyuan Zhao on 2022/3/19.
//

@testable import WelcomeModule
import ShellClient
import Git
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class WelcomeModuleUnitTests: XCTestCase {

    let record: Bool = false

    func testRecentProjectItemLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path")
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    func testRecentProjectItemDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path")
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    func testRecentJSFileLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path/test.js")
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    func testRecentJSFileDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: "Project Path/test.js")
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    func testWelcomeActionViewLightSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        ).preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }

    func testWelcomeActionViewDarkSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        ).preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image, record: record)
    }
}
