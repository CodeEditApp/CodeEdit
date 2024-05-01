//
//  UnitTests.swift
//  CodeEditModules/WelcomeModuleTests
//
//  Created by Ziyuan Zhao on 2022/3/19.
//

@testable import CodeEdit
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class WelcomeModuleUnitTests: XCTestCase {

    func testRecentProjectItemLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path"))
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testRecentProjectItemDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path"))
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testRecentJSFileLightSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path/test.js"))
            .preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testRecentJSFileDarkSnapshot() throws {
        let view = RecentProjectItem(projectPath: URL(fileURLWithPath: "Project Path/test.js"))
            .preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testWelcomeActionViewLightSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            action: { }
        ).preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testWelcomeActionViewDarkSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            action: { }
        ).preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }
}
