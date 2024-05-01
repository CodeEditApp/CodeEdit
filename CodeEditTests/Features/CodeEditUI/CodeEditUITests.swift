//
//  UnitTests.swift
//  CodeEditModules/CodeEditUITests
//
//  Created by Lukas Pistrol on 19.04.22.
//

@testable import CodeEdit
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class CodeEditUIUnitTests: XCTestCase {

    // MARK: Help Button

    func testHelpButtonLight() throws {
        let view = HelpButton(action: {})
        snapshot(view: view, size: .init(width: 40, height: 40), appearance: .light)
    }

    func testHelpButtonDark() throws {
        let view = HelpButton(action: {})
        snapshot(view: view, size: .init(width: 40, height: 40), appearance: .dark)
    }

    // MARK: Segmented Control

    func testSegmentedControlLight() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        snapshot(view: view, size: .init(width: 100, height: 30), appearance: .light)
    }

    func testSegmentedControlDark() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        snapshot(view: view, size: .init(width: 100, height: 30), appearance: .dark)
    }

    func testSegmentedControlProminentLight() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"], prominent: true)
        snapshot(view: view, size: .init(width: 100, height: 30), appearance: .light)
    }

    func testSegmentedControlProminentDark() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"], prominent: true)
        snapshot(view: view, size: .init(width: 100, height: 30), appearance: .dark)
    }

    // MARK: EffectView

    func testEffectViewLight() throws {
        let view = EffectView()
        snapshot(view: view, size: .init(width: 20, height: 20), appearance: .light)
    }

    func testEffectViewDark() throws {
        let view = EffectView()
        snapshot(view: view, size: .init(width: 20, height: 20), appearance: .dark)
    }

    // MARK: ToolbarBranchPicker

    func testBranchPickerLight() throws {
        let view = ToolbarBranchPicker(
            workspaceFileManager: nil
        )
        snapshot(view: view, size: .init(width: 100, height: 50), appearance: .light)
    }

    func testBranchPickerDark() throws {
        let view = ToolbarBranchPicker(
            workspaceFileManager: nil
        )
        snapshot(view: view, size: .init(width: 100, height: 50), appearance: .dark)
    }
}
