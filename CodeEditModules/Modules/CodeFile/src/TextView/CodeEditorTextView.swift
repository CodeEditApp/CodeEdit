//
//  CodeEditorTextView.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 19/03/22.
//

import Cocoa
import SwiftUI

public class CodeEditorTextView: NSTextView {
    @AppStorage(EditorTabWidth.storageKey)
    private var tabWidth: Int = EditorTabWidth.default

    init(
        textContainer container: NSTextContainer?
    ) {
        super.init(frame: .zero, textContainer: container)
        drawsBackground = true
        isEditable = true
        isHorizontallyResizable = false
        isVerticallyResizable = true
        allowsUndo = true
        isRichText = false
        isGrammarCheckingEnabled = false
        isContinuousSpellCheckingEnabled = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var swiftSelectedRange: Range<String.Index> {
        let string = self.string
        guard !string.isEmpty else { return string.startIndex..<string.startIndex }
        guard let selectedRange = Range(self.selectedRange(), in: string) else {
            assertionFailure("Could not convert the selectedRange")
            return string.startIndex..<string.startIndex
        }
        return selectedRange
    }
    private var currentLine: String {
        let string = self.string
        return String(string[string.lineRange(for: swiftSelectedRange)])
    }

    public override func insertNewline(_ sender: Any?) {
        // get line before newline
        let currentLine = self.currentLine
        let prefix = currentLine.prefix {
            guard let scalar = $0.unicodeScalars.first else {
                return false
            }

            return CharacterSet.whitespaces.contains(scalar)
        }

        super.insertNewline(sender)

        if !prefix.isEmpty {
            insertText(String(prefix), replacementRange: selectedRange())
        }
    }

    let autoPairs = [
        "(": ")",
        "{": "}",
        "[": "]",
        "\"": "\"",
    ]

    public override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        guard let string = string as? String,
              let end = autoPairs[string]
        else { return }
        super.insertText(end, replacementRange: selectedRange())
        super.moveBackward(self)
    }

    public override func insertTab(_ sender: Any?) {
        super.insertText(
            String(
                repeating: " ",
                count: tabWidth
            ),
            replacementRange: selectedRange()
        )
    }
}
