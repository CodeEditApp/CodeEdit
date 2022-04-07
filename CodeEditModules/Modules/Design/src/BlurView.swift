//
//  BlurView.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 15/03/2022.
//

import SwiftUI

public struct BlurView: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode

    public init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.followsWindowActiveState
        return visualEffectView
    }

    public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
