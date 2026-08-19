//
//  CopilotDocumentObjects.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation

/// A per-document bundle of GitHub Copilot objects, mirroring ``LanguageServerDocumentObjects``.
///
/// Stored on ``CodeFileDocument`` so it lives for the document's lifetime and keeps a strong reference to the
/// ``CopilotInlineCompletionProvider`` (the editor controller only holds the provider weakly).
struct CopilotDocumentObjects {
    /// The inline completion provider passed to the editor as its `inlineCompletionDelegate`.
    let provider = CopilotInlineCompletionProvider()

    /// Associates the provider with its document.
    @MainActor
    func setUp(document: CodeFileDocument) {
        provider.setUp(document: document)
    }
}
