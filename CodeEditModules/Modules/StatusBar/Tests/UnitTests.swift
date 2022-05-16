//
//  UnitTests.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 11.05.22.
//

@testable import StatusBar
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class StatusBarUnitTests: XCTestCase {

    func testStatusBarCollapsedLight() throws {
        let view = StatusBarView(model: .init(workspaceURL: URL(fileURLWithPath: "")))
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 600, height: 50))
        hosting.appearance = .init(named: .aqua)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testStatusBarCollapsedDark() throws {
        let view = StatusBarView(model: .init(workspaceURL: URL(fileURLWithPath: "")))
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 600, height: 50))
        hosting.appearance = .init(named: .darkAqua)
        assertSnapshot(matching: hosting, as: .image)
    }

    func testStatusBarExpandedLight() throws {
        let model = StatusBarModel(workspaceURL: URL(fileURLWithPath: ""))
        model.selectedTab = 1
        model.currentHeight = 300
        model.isExpanded = true
        let view = StatusBarView(model: model).preferredColorScheme(.light)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 600, height: 350))
        hosting.appearance = .init(named: .aqua)
        assertSnapshot(matching: hosting, as: .image(size: .init(width: 600, height: 350)))
    }

    func testStatusBarExpandedDark() throws {
        let model = StatusBarModel(workspaceURL: URL(fileURLWithPath: ""))
        model.selectedTab = 1
        model.currentHeight = 300
        model.isExpanded = true
        let view = StatusBarView(model: model).preferredColorScheme(.dark)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 600, height: 350))
        hosting.appearance = .init(named: .darkAqua)
        assertSnapshot(matching: hosting, as: .image(size: .init(width: 600, height: 350)))
    }

}
