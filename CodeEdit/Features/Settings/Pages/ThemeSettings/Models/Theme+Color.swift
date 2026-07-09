//
//  Theme+Color.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import CodeEditSettings
import CodeEditSourceEditor

/// Color conversion extensions for Theme types.
/// These bridge between the hex string storage format and SwiftUI/AppKit color types.

extension Theme.Attributes {
    /// The `SwiftUI` color of ``color``
    var swiftColor: Color {
        get {
            Color(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }

    /// The `NSColor` of ``color``
    var nsColor: NSColor {
        get {
            NSColor(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}

extension Theme.EditorColors {
    var editorTheme: EditorTheme {
        get {
            .init(
                text: .init(color: text.nsColor),
                insertionPoint: insertionPoint.nsColor,
                invisibles: .init(color: invisibles.nsColor),
                background: background.nsColor,
                lineHighlight: lineHighlight.nsColor,
                selection: selection.nsColor,
                keywords: .init(color: keywords.nsColor),
                commands: .init(color: commands.nsColor),
                types: .init(color: types.nsColor),
                attributes: .init(color: attributes.nsColor),
                variables: .init(color: variables.nsColor),
                values: .init(color: values.nsColor),
                numbers: .init(color: numbers.nsColor),
                strings: .init(color: strings.nsColor),
                characters: .init(color: characters.nsColor),
                comments: .init(color: comments.nsColor)
            )
        }
        set {
            self.text.nsColor = newValue.text.color
            self.insertionPoint.nsColor = newValue.insertionPoint
            self.invisibles.nsColor = newValue.invisibles.color
            self.background.nsColor = newValue.background
            self.lineHighlight.nsColor = newValue.lineHighlight
            self.selection.nsColor = newValue.selection
            self.keywords.nsColor = newValue.keywords.color
            self.commands.nsColor = newValue.commands.color
            self.types.nsColor = newValue.types.color
            self.attributes.nsColor = newValue.attributes.color
            self.variables.nsColor = newValue.variables.color
            self.values.nsColor = newValue.values.color
            self.numbers.nsColor = newValue.numbers.color
            self.strings.nsColor = newValue.strings.color
            self.characters.nsColor = newValue.characters.color
            self.comments.nsColor = newValue.comments.color
        }
    }
}
