//
//  Snapshotting.swift
//  CodeEditTests
//
//  Created by Khan Winter on 4/30/24.
//

import SnapshotTesting
import XCTest
import AppKit
import SwiftUI

/// A NSWindow which can be configured in a deterministic way.
public final class GenericWindow: NSWindow {
    static let standard = GenericWindow(backingScaleFactor: 1.0, colorSpace: .displayP3)

    public init(backingScaleFactor: CGFloat = 1.0, colorSpace: NSColorSpace? = nil) {
        self._backingScaleFactor = backingScaleFactor
        self._explicitlySpecifiedColorSpace = colorSpace

        super.init(contentRect: NSRect.zero, styleMask: [], backing: .buffered, defer: true)
    }

    private let _explicitlySpecifiedColorSpace: NSColorSpace?
    private var _systemSpecifiedColorspace: NSColorSpace?

    private let _backingScaleFactor: CGFloat
    override public var backingScaleFactor: CGFloat {
        return _backingScaleFactor
    }

    override public var colorSpace: NSColorSpace? {
        get {
            _explicitlySpecifiedColorSpace ?? self._systemSpecifiedColorspace
        }
        set {
            self._systemSpecifiedColorspace = newValue
        }
    }
}

/// Appearance of a snapshot
enum Appearance {
    case light
    case dark
}

/// Assert a snapshot of a view.
/// - Parameters:
///   - view: The view to assert.
///   - name: An optional name for the snapshot.
///   - recording: Set to true to override any existing snapshots.
///   - timeout: The timeout before failing.
///   - file: The file the test is in.
///   - testName: The name of the test.
///   - line: The line of the caller.
///   - precision: How precisely to compare snapshots.
///   - perceptualPrecision: How precisely to compare snapshots, using a human perception algorithm.
///   - size: The size of the view.
///   - appearance: What appearance to use.
///   - windowForDrawing: The window to use for drawing. In most cases this should be the standard one.
func snapshot(
    view: NSView,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    size: CGSize? = nil,
    appearance: Appearance = .light,
    windowForDrawing: GenericWindow = .standard
) {
    // Code here based on:
    // https://github.com/pointfreeco/swift-snapshot-testing/pull/533
    //
    // Once that PR is merged, this should be replaced with a simple wrapper around the built-in swift-snapshot
    // method for snapshotting views.
    // For now, this makes it so we have a consistent screen resolution across test machines whether that's the test
    // runner mac mini or a maintainer's macbook pro.

    let initialSize = view.frame.size
    if let size = size {
        view.frame.size = size
    }
    guard view.frame.width > 0, view.frame.height > 0 else {
        fatalError("View not renderable to image at size \(view.frame.size)")
    }

    let initialAppearance = view.appearance
    switch appearance {
    case .light:
        view.appearance = NSAppearance(named: .aqua)
    case .dark:
        view.appearance = NSAppearance(named: .darkAqua)
    }

    precondition(
        view.window == nil,
        """
        If choosing to draw the view using a new window, the view must not already be attached to an existing window. \
        (We wouldn’t be able to easily restore the view and all its associated constraints to the original window \
        after moving it to the new window.)
        """
    )
    windowForDrawing.contentView = NSView()
    windowForDrawing.contentView?.addSubview(view)

    let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
    view.cacheDisplay(in: view.bounds, to: bitmapRep)
    let image = NSImage(size: view.bounds.size)
    image.addRepresentation(bitmapRep)

    assertSnapshot(
        of: image,
        as: .image(precision: precision, perceptualPrecision: perceptualPrecision),
        named: name,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )

    view.frame.size = initialSize
    view.appearance = initialAppearance
}

/// Assert a snapshot of a view.
/// - Parameters:
///   - view: The view to assert.
///   - name: An optional name for the snapshot.
///   - recording: Set to true to override any existing snapshots.
///   - timeout: The timeout before failing.
///   - file: The file the test is in.
///   - testName: The name of the test.
///   - line: The line of the caller.
///   - precision: How precisely to compare snapshots.
///   - perceptualPrecision: How precisely to compare snapshots, using a human perception algorithm.
///   - size: The size of the view.
///   - appearance: What appearance to use.
///   - windowForDrawing: The window to use for drawing. In most cases this should be the standard one.
func snapshot(
    view: some View,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    size: CGSize? = nil,
    appearance: Appearance = .light,
    windowForDrawing: GenericWindow = .standard
) {
    let hostingView = NSHostingView(rootView: view.preferredColorScheme(appearance == .light ? .light : .dark))
    snapshot(
        view: hostingView,
        named: name,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line,
        precision: precision,
        perceptualPrecision: perceptualPrecision,
        size: size,
        appearance: appearance,
        windowForDrawing: windowForDrawing
    )
}
