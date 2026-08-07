//
//  LanguageServerDocument.swift
//  CodeEdit
//
//  Created by Khan Winter on 2/12/25.
//

import AppKit
import CodeEditDocument
import CodeEditLanguages

/// A set of properties a language server sets when a document is registered.
/// Main-actor isolated: its members are editor-facing (text coordinator, highlight
/// provider) and are created/used from the main actor by `LSPService`.
@MainActor
struct LanguageServerDocumentObjects<DocumentType: LanguageServerDocument> {
    var textCoordinator: LSPContentCoordinator<DocumentType> = LSPContentCoordinator()
    // swiftlint:disable:next line_length
    var highlightProvider: SemanticTokenHighlightProvider<SemanticTokenStorage, DocumentType> = SemanticTokenHighlightProvider()

    func setUp(server: LanguageServer<DocumentType>, document: DocumentType) {
        textCoordinator.setUp(server: server, document: document)
        highlightProvider.setUp(server: server, document: document)
    }
}

/// A protocol that allows a language server to work with a text document.
///
/// Deliberately holds no LSP-typed state: the per-document objects
/// (``LanguageServerDocumentObjects``) are owned by `LSPService`, keyed by URI, so conformers
/// (e.g. `CodeFileDocument`) need not depend on LSP types.
public protocol LanguageServerDocument: AnyObject {
    var content: NSTextStorage? { get }
    var languageServerURI: String? { get }
    func getLanguage() -> CodeLanguage
}
