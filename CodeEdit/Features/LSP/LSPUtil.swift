//
//  LSPUtil.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/10/24.
//

import Foundation
import LanguageServerProtocol

enum LSPCompletionItemsUtil {

    /// Helper function to get the edits from a completion item
    /// - Parameters:
    ///  - startPosition: The position where the completion was requested
    ///  - item: The completion item
    ///  - Returns: An array of TextEdit objects
    static func getCompletionItemEdits(startPosition: Position, item: CompletionItem) -> [TextEdit] {
        var edits: [TextEdit] = []

        // Handle text edits or insert-replace edits
        if let edit = item.textEdit {
            processEdit(edit: edit, into: &edits)
        }
        // Handle insert text
        else if let insertText = item.insertText {
            edits.append(createTextEdit(from: startPosition, text: insertText))
        }
        // Fallback to the label if available
        else if !item.label.isEmpty {
            edits.append(createTextEdit(from: startPosition, text: item.label))
        }

        // Add additional edits, if any
        if let additionalEdits = item.additionalTextEdits {
            edits.append(contentsOf: additionalEdits)
        }

        return edits
    }

    private static func processEdit(edit: TwoTypeOption<TextEdit, InsertReplaceEdit>, into edits: inout [TextEdit]) {
        switch edit {
        case .optionA(let textEdit):
            edits.append(textEdit)
        case .optionB(let insertReplaceEdit):
            edits.append(contentsOf: [
                TextEdit(range: insertReplaceEdit.insert, newText: insertReplaceEdit.newText),
                TextEdit(range: insertReplaceEdit.replace, newText: insertReplaceEdit.newText)
            ])
        }
    }

    private static func createTextEdit(from startPosition: Position, text: String) -> TextEdit {
        let endPosition = calculateEndPosition(from: startPosition, text: text)
        return TextEdit(range: LSPRange(start: startPosition, end: endPosition), newText: text)
    }

    private static func calculateEndPosition(from startPosition: Position, text: String) -> Position {
        // Avoid overflowing position by ensuring `character` stays within valid bounds
        return Position((startPosition.line, startPosition.character + text.count))
    }
}
