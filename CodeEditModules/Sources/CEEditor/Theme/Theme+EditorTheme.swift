//
//  Theme+EditorTheme.swift
//  Editor
//
//  Created by Matthijs Eikelenboom on 10.07.26.
//

import CodeEditCore
import CodeEditSourceEditor
import AppKit

public extension Theme.EditorColors {
    /// Bridges the settings theme's editor colors to a source editor `EditorTheme`.
    var editorTheme: EditorTheme {
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
}
