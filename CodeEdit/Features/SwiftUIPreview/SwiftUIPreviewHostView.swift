//
//  SwiftUIPreviewHostView.swift
//  CodeEdit
//
//  Created by Aryan Rogye on 5/4/26.
//

import AppKit
import SwiftUI

struct SwiftUIPreviewHostView: NSViewRepresentable {
    let previewView: NSView?

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.subviews.forEach { $0.removeFromSuperview() }

        guard let previewView else {
            return
        }

        previewView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(previewView)

        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: nsView.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor)
        ])
    }
}
