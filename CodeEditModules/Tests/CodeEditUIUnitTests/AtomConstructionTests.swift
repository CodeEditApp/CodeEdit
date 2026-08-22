//
//  AtomConstructionTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/07/26.
//

import Testing
import SwiftUI
import AppKit
import CodeEditUI

/// Construction/behavior smoke tests for the shared atoms formerly covered by the
/// (plan-skipped, deleted) pixel-snapshot suite. Views are materialized in an
/// offscreen window; no reference images.
@MainActor
struct AtomConstructionTests {
    private func materialize(_ view: some View, appearance: NSAppearance.Name) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.appearance = NSAppearance(named: appearance)
        window.contentView = NSHostingView(rootView: view)
        window.layoutIfNeeded()
        return window
    }

    @Test(arguments: [NSAppearance.Name.aqua, .darkAqua])
    func helpButtonHasIntrinsicSize(appearance: NSAppearance.Name) throws {
        let window = materialize(HelpButton(action: {}), appearance: appearance)
        let hosting = try #require(window.contentView as? NSHostingView<HelpButton>)
        #expect(hosting.fittingSize.width > 0)
        #expect(hosting.fittingSize.height > 0)
    }

    @Test(arguments: [false, true])
    func segmentedControlHasIntrinsicSize(prominent: Bool) throws {
        let view = SegmentedControl(.constant(0), options: ["One", "Two"], prominent: prominent)
        let window = materialize(view, appearance: .aqua)
        let hosting = try #require(window.contentView as? NSHostingView<SegmentedControl>)
        #expect(hosting.fittingSize.width > 0)
        #expect(hosting.fittingSize.height > 0)
    }

    @Test
    func effectViewMaterializesAVisualEffectView() throws {
        let window = materialize(EffectView(), appearance: .aqua)

        func containsVisualEffectView(_ view: NSView) -> Bool {
            if view is NSVisualEffectView { return true }
            return view.subviews.contains(where: containsVisualEffectView)
        }

        #expect(containsVisualEffectView(try #require(window.contentView)))
    }
}
