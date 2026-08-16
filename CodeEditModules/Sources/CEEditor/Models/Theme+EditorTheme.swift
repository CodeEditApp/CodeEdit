//
//  Theme+EditorTheme.swift
//  Editor
//
//  Created by Matthijs Eikelenboom on 10.07.26.
//

import CodeEditCore
import CodeEditSettings
import CodeEditSourceEditor
import AppKit

public extension Theme.EditorColors {
    /// Bridges the settings theme's editor colors to a source editor `EditorTheme`, converting in both directions.
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
