//
//  LanguageServerFileMap.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/8/24.
//

import Foundation
import LanguageServerProtocol

/// Tracks data associated with files and language servers.
class LanguageServerFileMap<DocumentType: LanguageServerDocument> {
    typealias HighlightProviderType = SemanticTokenHighlightProvider<SemanticTokenStorage, DocumentType>

    /// Extend this struct as more objects are associated with a code document.
    private struct DocumentObject {
        let uri: String
        var documentVersion: Int
        var contentCoordinator: LSPContentCoordinator<DocumentType>
        var semanticHighlighter: HighlightProviderType?
    }

    private var trackedDocuments: NSMapTable<NSString, DocumentType>
    private var trackedDocumentData: [String: DocumentObject] = [:]

    init() {
        trackedDocuments = NSMapTable<NSString, DocumentType>(valueOptions: [.weakMemory])
    }

    // MARK: - Track & Remove Documents

    func addDocument(_ document: DocumentType, for server: LanguageServer<DocumentType>) {
        guard let uri = document.languageServerURI else { return }
        trackedDocuments.setObject(document, forKey: uri as NSString)
        var docData = DocumentObject(
            uri: uri,
            documentVersion: 0,
            contentCoordinator: LSPContentCoordinator(
                documentURI: uri,
                languageServer: server
            ),
            semanticHighlighter: nil
        )

        if let tokenMap = server.highlightMap {
            docData.semanticHighlighter = HighlightProviderType(
                tokenMap: tokenMap,
                languageServer: server,
                documentURI: uri
            )
        }

        trackedDocumentData[uri] = docData
    }

    func document(for uri: DocumentUri) -> DocumentType? {
        return trackedDocuments.object(forKey: uri as NSString)
    }

    func removeDocument(for document: DocumentType) {
        guard let uri = document.languageServerURI else { return }
        removeDocument(for: uri)
    }

    func removeDocument(for uri: DocumentUri) {
        trackedDocuments.removeObject(forKey: uri as NSString)
        trackedDocumentData.removeValue(forKey: uri)
    }

    // MARK: - Version Number Tracking

    func incrementVersion(for document: DocumentType) -> Int {
        guard let uri = document.languageServerURI else { return 0 }
        return incrementVersion(for: uri)
    }

    func incrementVersion(for uri: DocumentUri) -> Int {
        trackedDocumentData[uri]?.documentVersion += 1
        return trackedDocumentData[uri]?.documentVersion ?? 0
    }

    func documentVersion(for document: DocumentType) -> Int? {
        guard let uri = document.languageServerURI else { return nil }
        return documentVersion(for: uri)
    }

    func documentVersion(for uri: DocumentUri) -> Int? {
        return trackedDocumentData[uri]?.documentVersion
    }

    // MARK: - Content Coordinator

    func contentCoordinator(for document: DocumentType) -> LSPContentCoordinator<DocumentType>? {
        guard let uri = document.languageServerURI else { return nil }
        return contentCoordinator(for: uri)
    }

    func contentCoordinator(for uri: DocumentUri) -> LSPContentCoordinator<DocumentType>? {
        trackedDocumentData[uri]?.contentCoordinator
    }

    // MARK: - Semantic Highlighter

    func semanticHighlighter(for document: DocumentType) -> HighlightProviderType? {
        guard let uri = document.languageServerURI else { return nil }
        return trackedDocumentData[uri]?.semanticHighlighter
    }
}
