//
//  LSPUtil.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/10/24.
//

import Foundation
import LanguageServerProtocol

/// Helper function to get the edits from a completion item
/// - Parameters:
///  - startPosition: The position where the completion was requested
///  - item: The completion item
///  - Returns: An array of TextEdit objects
func getCompletionItemEdits(startPosition: Position, item: CompletionItem) -> [TextEdit] {
    var edits: [TextEdit] = []

    // If a TextEdit or InsertReplaceEdit value was provided
    if let edit = item.textEdit {
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
    // If the `insertText` value was provided
    else if let insertText = item.insertText {
        // TODO: COMPUTE EDIT BY FINDING MATCHING TEXT, ALSO CHECK FOR TRIGGER CHARACTERS
        edits.append(
            TextEdit(
                range: LSPRange(from: startPosition, offsetCharacter: insertText.count),
                newText: insertText
            )
        )
    }
    // Fallback to the label
    else if item.label != "" {
        // TODO: COMPUTE EDIT BY FINDING MATCHING TEXT, ALSO CHECK FOR TRIGGER CHARACTERS
        edits.append(
            TextEdit(
                range: LSPRange(from: startPosition, offsetCharacter: item.label.count),
                newText: item.label
            )
        )
    }

    // If additional edits were provided
    // An example would be to also include an 'import' statement at the top of the file
    if let additionalEdits = item.additionalTextEdits {
        edits.append(contentsOf: additionalEdits)
    }

    return edits
}
