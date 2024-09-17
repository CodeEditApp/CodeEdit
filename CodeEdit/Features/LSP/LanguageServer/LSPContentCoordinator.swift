//
//  LSPContentCoordinator.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/12/24.
//

import AppKit
import CodeEditSourceEditor
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

/// This content coordinator forwards content notifications from the editor's text storage to a language service.
///
/// This is a text view coordinator so that it can be installed on an open editor. It is kept as a property on
/// ``CodeFileDocument`` since the language server does all it's document management using instances of that type.
class LSPContentCoordinator: TextViewCoordinator, TextViewDelegate {
    private var editedRange: LSPRange?

    weak var languageServer: LanguageServer?
    var uri: String?

    func prepareCoordinator(controller: TextViewController) { }

    /// We grab the lsp range before the content (and layout) is changed so we get correct line/col info for the
    /// language server range.
    func textView(_ textView: TextView, willReplaceContentsIn range: NSRange, with string: String) {
        self.editedRange = textView.lspRangeFrom(nsRange: range)
    }

    func textView(_ textView: TextView, didReplaceContentsIn range: NSRange, with string: String) {
        guard let uri,
              let languageServer = languageServer,
              let lspRange = editedRange else {
            return
        }
        self.editedRange = nil
        Task.detached { // Detached to get off the main actor ASAP
            try await languageServer.documentChanged(uri: uri, replacedContentIn: lspRange, with: string)
        }
    }
}
