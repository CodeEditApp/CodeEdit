//
//  GlassEffectView.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/2/25.
//

import SwiftUI
import AppKit

public struct GlassEffectView: NSViewRepresentable {
    var tintColor: NSColor?

    public init(tintColor: NSColor? = nil) {
        self.tintColor = tintColor
    }

    public func makeNSView(context: Context) -> NSView {
#if compiler(>=6.2)
        if #available(macOS 26, *) {
            let view = NSGlassEffectView()
            view.cornerRadius = 0
            view.tintColor = tintColor
            return view
        }
#endif
        return NSView()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
#if compiler(>=6.2)
        if #available(macOS 26, *), let view = nsView as? NSGlassEffectView {
            view.tintColor = tintColor
        }
#endif
    }
}
