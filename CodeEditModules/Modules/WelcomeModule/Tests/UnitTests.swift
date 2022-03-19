//
//  UnitTests.swift
//  
//
//  Created by Ziyuan Zhao on 2022/3/19.
//

@testable import WelcomeModule
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class CodeFileUnitTests: XCTestCase {
    func testRecentProjectItemNormalSnapshot() throws {
        let view = RecentProjectItem(
            isSelected: .constant(false),
            projectName: "Project Name",
            projectPath: "Project Path"
        )
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testRecentProjectItemSelectedSnapshot() throws {
        let view = RecentProjectItem(
            isSelected: .constant(true),
            projectName: "Project Name",
            projectPath: "Project Path"
        )
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testWelcomeActionViewSnapshot() throws {
        let view = WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        )
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        assertSnapshot(matching: hosting, as: .image)
    }
}
