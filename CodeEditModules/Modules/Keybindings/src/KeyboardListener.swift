//
//  KeyboardListener.swift
//  CodeEdit
//
//  Created by Khan Winter on 4/24/22.
//

import SwiftUI
import AppKit

// swiftlint:disable missing_docs
extension View {
    public func keyboardListener(keys: [UInt16],
                                 modifiers: NSEvent.ModifierFlags?,
                                 onDown: (() -> Void)?
                                 ) -> some View {
        modifier(KeyboardListenerModifier(keys: keys, modifiers: modifiers, onDown: onDown))
    }
}

struct KeyboardListenerModifier: ViewModifier {
    let keys: [UInt16]
    let modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            KeyboardListener(keys: keys, modifiers: modifiers, onDown: onDown)
            TextInput()
            content
        }
    }
}

public struct KeyboardListener: NSViewRepresentable {
    let keys: [UInt16]
    let modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?

    public func makeNSView(context: Context) -> some NSView {
        let view = KeyboardListenerView()
        view.keys = keys
        view.modifiers = modifiers
        view.onDown = onDown
        return view
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {

    }

}

public struct TextInput: NSViewRepresentable {
    public func makeNSView(context: Context) -> some NSView {
        let view = NSTextField()
        return view
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {

    }
}

class KeyboardListenerView: NSView {
    var keys: [UInt16] = []
    var modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?

    private var modifiersPressed: Bool = false

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func flagsChanged(with event: NSEvent) {
        modifiersPressed = event.modifierFlags.intersection(.deviceIndependentFlagsMask) == modifiers
        if keyCommandMatches(eventKey: event.keyCode) {
            onDown?()
        }
    }
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        if keyCommandMatches(eventKey: event.keyCode) {
            onDown?()
        }
    }

    /// Returns `true` if the current key-flag combination matches.
    /// - Returns: `true` if the current key-flag combination matches the keyboard's pressed keys.
    private func keyCommandMatches(eventKey: UInt16) -> Bool {
        return keys.contains(eventKey) && modifiersPressed // && !didEscape
    }

    deinit {
        onDown = nil
    }
}
