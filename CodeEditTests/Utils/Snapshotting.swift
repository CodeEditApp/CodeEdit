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
@testable import CodeEdit

/// A NSWindow which can be configured in a deterministic way.
public final class GenericWindow: NSWindow {
    public init(backingScaleFactor: CGFloat = 2.0, colorSpace: NSColorSpace? = nil) {
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

extension GenericWindow {
    static let standard = GenericWindow(backingScaleFactor: 1.0, colorSpace: .displayP3)
}

enum Appearance {
    case light
    case dark
}

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
