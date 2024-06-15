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

        // If a TextEdit or InsertReplaceEdit value was provided
        if let edit = item.textEdit {
            editOrReplaceItem(edit: edit, &edits)
        } else if let insertText = item.insertText {
            // If the `insertText` value was provided
            insertTextItem(startPosition: startPosition, insertText: insertText, &edits)
        } else if !item.label.isEmpty {
            // Fallback to the label
            labelItem(startPosition: startPosition, label: item.label, &edits)
        }

        // If additional edits were provided
        // An example would be to also include an 'import' statement at the top of the file
        if let additionalEdits = item.additionalTextEdits {
            edits.append(contentsOf: additionalEdits)
        }

        return edits
    }

    private static func editOrReplaceItem(edit: TwoTypeOption<TextEdit, InsertReplaceEdit>, _ edits: inout [TextEdit]) {
        switch edit {
        case .optionA(let textEdit):
            edits.append(textEdit)
        case .optionB(let insertReplaceEdit):
            edits.append(
                TextEdit(range: insertReplaceEdit.insert, newText: insertReplaceEdit.newText)
            )
            edits.append(
                TextEdit(range: insertReplaceEdit.replace, newText: insertReplaceEdit.newText)
            )
        }
    }

    private static func insertTextItem(startPosition: Position, insertText: String, _ edits: inout [TextEdit]) {
        let endPosition = Position((startPosition.line, startPosition.character + insertText.count))
        edits.append(
            TextEdit(
                range: LSPRange(start: startPosition, end: endPosition),
                newText: insertText
            )
        )
    }

    private static func labelItem(startPosition: Position, label: String, _ edits: inout [TextEdit]) {
        let endPosition = Position((startPosition.line, startPosition.character + label.count))
        edits.append(
            TextEdit(
                range: LSPRange(start: startPosition, end: endPosition),
                newText: label
            )
        )
    }
}
