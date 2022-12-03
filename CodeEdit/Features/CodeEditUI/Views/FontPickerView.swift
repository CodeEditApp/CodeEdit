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
    private let labelString: String

    @State
    private var fontPickerDelegate: FontPickerDelegate?

    @Binding
    private var fontName: String

    @Binding
    private var fontSize: Int

    private var font: NSFont {
        get {
            NSFont(name: fontName, size: CGFloat(fontSize)) ?? .systemFont(ofSize: CGFloat(fontSize))
        }
        set {
            self.fontName = newValue.fontName
            self.fontSize = Int(newValue.pointSize)
        }
    }

    init(_ label: String, name: Binding<String>, size: Binding<Int>) {
        self.labelString = label
        self._fontName = name
        self._fontSize = size
    }

    var body: some View {
        HStack {
            Text(labelString)
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

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker("Font Picker", name: .constant("SF-MonoMedium"), size: .constant(11))
            .padding()
    }
}
