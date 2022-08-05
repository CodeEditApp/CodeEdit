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
    public func keyboardListener(keys: Set<Character>,
                                 modifiers: NSEvent.ModifierFlags?,
                                 onDown: (() -> Void)?,
                                 onUp: (() -> Void)?) -> some View {
        modifier(KeyboardListenerModifier(keys: keys, modifiers: modifiers, onDown: onDown, onUp: onUp))
    }
}

struct KeyboardListenerModifier: ViewModifier {
    let keys: Set<Character>
    let modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?
    var onUp: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            KeyboardListener(keys: keys, modifiers: modifiers, onDown: onDown, onUp: onUp)
            content
        }
    }
}

public struct KeyboardListener: NSViewRepresentable {
    let keys: Set<Character>
    let modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?
    var onUp: (() -> Void)?

    public func makeNSView(context: Context) -> some NSView {
        let view = KeyboardListenerView()
        view.keys = keys
        view.modifiers = modifiers
        view.onDown = onDown
        view.onUp = onUp
        return view
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {

    }

}

class KeyboardListenerView: NSView {
    var keys: Set<Character> = []
    var modifiers: NSEvent.ModifierFlags?
    var onDown: (() -> Void)?
    var onUp: (() -> Void)?

    private var modifiersPressed: Bool = false
    private var charactersPressed: Set<Character> = []

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func flagsChanged(with event: NSEvent) {
        modifiersPressed = event.modifierFlags.intersection(.deviceIndependentFlagsMask) == modifiers
        if keyCommandMatches() {
            onDown?()
        } else if charactersPressed.isEmpty && modifiersPressed == false {
            onUp?()
        }
    }
    override func keyDown(with event: NSEvent) {
        for char in event.characters ?? "" {
            charactersPressed.insert(char)
        }
        if keyCommandMatches() {
            onDown?()
        }
    }
    override func keyUp(with event: NSEvent) {
        for char in event.characters ?? "" {
            charactersPressed.remove(char)
        }
        if charactersPressed.isEmpty && modifiersPressed == false {
            onUp?()
        }
    }

    /// Returns `true` if the current key-flag combination matches.
    /// - Returns: `true` if the current key-flag combination matches the keyboard's pressed keys.
    private func keyCommandMatches() -> Bool {
        return charactersPressed == keys && modifiersPressed // && !didEscape
    }

    deinit {
        onDown = nil
        onUp = nil
    }
}
