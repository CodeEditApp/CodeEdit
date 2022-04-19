//
//  UnitTests.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.04.22.
//

@testable import CodeEditUI
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class CodeEditUIUnitTests: XCTestCase {

    // MARK: Help Button

    func testHelpButtonLight() throws {
        let view = HelpButton(action: {})
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 40, height: 40))
        hosting.appearance = .init(named: .aqua)
        assertSnapshot(matching: hosting, as: .image(size: .init(width: 40, height: 40)))
    }

    func testHelpButtonDark() throws {
        let view = HelpButton(action: {})
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 40, height: 40))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: Segmented Control

    func testSegmentedControlLight() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    func testSegmentedControlDark() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: FontPickerView

    func testFontPickerViewLight() throws {
        let view = FontPicker("Font", name: .constant("SF-Mono"), size: .constant(13))
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 120, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    func testFontPickerViewDark() throws {
        let view = FontPicker("Font", name: .constant("SF-Mono"), size: .constant(13))
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 120, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: EffectView

    func testEffectViewLight() throws {
        let view = EffectView()
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
        assertSnapshot(matching: hosting, as: .image)
    }

    func testEffectViewDark() throws {
        let view = EffectView()
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
        assertSnapshot(matching: hosting, as: .image)
    }
}
