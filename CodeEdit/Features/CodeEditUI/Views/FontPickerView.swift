//
//  FontPickerView.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

final class FontPickerDelegate {
    var parent: FontPicker

    init(_ parent: FontPicker) {
        self.parent = parent
    }

    @objc
    func changeFont(_ id: Any) {
        parent.fontSelected()
    }

}

/// A view that opens a `NSFontPanel` in order to choose a font installed on the system.
struct FontPicker: View {
    @State
    private var fontPickerDelegate: FontPickerDelegate?

    @Binding
    private var fontName: String

    @Binding
    private var fontSize: Double

    private var font: NSFont {
        get {
            NSFont(name: fontName, size: CGFloat(fontSize)) ?? .systemFont(ofSize: CGFloat(fontSize))
        }
        set {
            self.fontName = newValue.fontName
            self.fontSize = newValue.pointSize
        }
    }

    init(name: Binding<String>, size: Binding<Double>) {
        self._fontName = name
        self._fontSize = size
    }

    var body: some View {
        HStack {
            Text("Custom Font")
            Spacer()
            Text(fontName)
                .lineLimit(1)
                .truncationMode(.middle)
            Button {
                if NSFontPanel.shared.isVisible {
                    NSFontPanel.shared.orderOut(nil)
                    return
                }

                self.fontPickerDelegate = FontPickerDelegate(self)
                NSFontManager.shared.target = self.fontPickerDelegate
                NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
                NSFontPanel.shared.orderBack(nil)
            } label: {
                Text("Select...")
            }
            .fixedSize()
        }
    }

    mutating
    func fontSelected() {
        self.font = NSFontPanel.shared.convert(self.font)
    }
}
