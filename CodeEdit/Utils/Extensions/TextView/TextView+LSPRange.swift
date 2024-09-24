//
//  TextView+LSPRange.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/21/24.
//

import AppKit
import CodeEditTextView
import LanguageServerProtocol

extension TextView {
    func lspRangeFrom(nsRange: NSRange) -> LSPRange? {
        guard let startLine = layoutManager.textLineForOffset(nsRange.location),
              let endLine = layoutManager.textLineForOffset(nsRange.max) else {
            return nil
        }
        return LSPRange(
            start: Position(line: startLine.index, character: nsRange.location - startLine.range.location),
            end: Position(line: endLine.index, character: nsRange.max - endLine.range.location)
        )
    }
}
