//
//  BlurView.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 15/03/2022.
//

import Foundation
import SwiftUI

struct BlurView: NSViewRepresentable {
    
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { }
    
}
