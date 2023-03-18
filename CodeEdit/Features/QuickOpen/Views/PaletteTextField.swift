//
//  PaletteTextField.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 18/03/2023.
//

import SwiftUI

struct PaletteTextField: NSViewRepresentable {
    @Binding var text: String

    var overruleKeyCode: (Int) -> Void

    func makeNSView(context: Context) -> PaletteNSTextView {
        let view = PaletteNSTextView()
        view.overruleKeyCode = overruleKeyCode

        view.string = text
        view.font = .systemFont(ofSize: 20, weight: .light)
        view.drawsBackground = false
        view.becomeFirstResponder()
        view.invalidateIntrinsicContentSize()
        view.textContainer!.maximumNumberOfLines = 1
        view.delegate = context.coordinator

        return view
    }

    func updateNSView(_ view: PaletteNSTextView, context: Context) {
        view.string = text
        view.overruleKeyCode = overruleKeyCode
    }

    func makeCoordinator() -> Delegate {
        Delegate(parent: self)
    }
}

extension PaletteTextField {
    class Delegate: NSObject, NSTextViewDelegate {
        var parent: PaletteTextField

        init(parent: PaletteTextField) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textview = notification.object as? NSTextView {
                parent.text = textview.string
            }
        }
    }
}

extension PaletteTextField {
    class PaletteNSTextView: NSTextView {

        var overruleKeyCode: ((Int) -> Void)?

        override var acceptsFirstResponder: Bool { return true }

        override public func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 36, 125, 126:
                overruleKeyCode?(Int(event.keyCode))
            default:
                super.keyDown(with: event)
            }
        }
    }
}
