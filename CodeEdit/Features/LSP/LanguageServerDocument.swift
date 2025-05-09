//
//  LanguageServerDocument.swift
//  CodeEdit
//
//  Created by Khan Winter on 2/12/25.
//

import AppKit
import CodeEditLanguages

/// A set of properties a language server sets when a document is registered.
struct LanguageServerDocumentObjects<DocumentType: LanguageServerDocument> {
    var textCoordinator: LSPContentCoordinator<DocumentType>?
    var highlightProvider: SemanticTokenHighlightProvider<SemanticTokenStorage, DocumentType>?
}

/// A protocol that allows a language server to register objects on a text document.
protocol LanguageServerDocument: AnyObject {
    var content: NSTextStorage? { get }
    var languageServerURI: String? { get }
    var languageServerObjects: LanguageServerDocumentObjects<Self> { get set }
    func getLanguage() -> CodeLanguage
}
