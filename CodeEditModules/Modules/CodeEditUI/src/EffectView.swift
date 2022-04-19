//
//  BlurView.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 15/03/2022.
//

import SwiftUI

/// A SwiftUI Wrapper for `NSVisualEffectView`
///
/// ## Usage
/// ```swift
/// EffectView(material: .headerView, blendingMode: .withinWindow)
/// ```
public struct EffectView: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode

    /// Initializes the `NSVisualEffectView` with a
    /// [`Material`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/material) and
    /// [`BlendingMode`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/blendingmode)
    /// - Parameters:
    ///   - material: The material to use. Defaults to `.headerView`.
    ///   - blendingMode: The blending mode to use. Defaults to `.withinWindow`.
    public init(
        _ material: NSVisualEffectView.Material = .headerView,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = NSVisualEffectView.State.followsWindowActiveState
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
