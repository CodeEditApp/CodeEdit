//
//  GlassEffectView.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/2/25.
//

import SwiftUI
import AppKit

struct GlassEffectView: NSViewRepresentable {
    var tintColor: NSColor?

    init(tintColor: NSColor? = nil) {
        self.tintColor = tintColor
    }

    func makeNSView(context: Context) -> NSView {
        if #available(macOS 26, *) {
            let view = NSGlassEffectView()
            view.cornerRadius = 0
            view.tintColor = tintColor
            return view
        } else {
            return NSView()
        }
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if #available(macOS 26, *), let view = nsView as? NSGlassEffectView {
            view.tintColor = tintColor
        }
    }
}
