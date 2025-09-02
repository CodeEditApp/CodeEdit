//
//  GlassEffectView.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/2/25.
//


struct GlassEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        if #available(macOS 26, *) {
            let view = NSGlassEffectView()
            view.cornerRadius = 0
            view.tintColor = .clear
            return view
        } else {
            return NSView()
        }
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}
