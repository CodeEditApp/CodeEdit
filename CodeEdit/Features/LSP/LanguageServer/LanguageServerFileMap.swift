//
//  LanguageServerFileMap.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/8/24.
//

import Foundation
import LanguageServerProtocol

/// Tracks data associated with files and language servers.
class LanguageServerFileMap {
    /// Extend this struct as more objects are associated with a code document.
    private struct DocumentObject {
        let uri: String
        var documentVersion: Int
        var contentCoordinator: LSPContentCoordinator
    }

    private var trackedDocuments: NSMapTable<NSString, CodeFileDocument>
    private var trackedDocumentData: [String: DocumentObject] = [:]

    init() {
        trackedDocuments = NSMapTable<NSString, CodeFileDocument>(valueOptions: [.weakMemory])
    }

    // MARK: - Track & Remove Documents

    func addDocument(_ document: CodeFileDocument, for server: LanguageServer) {
        guard let uri = document.languageServerURI else { return }
        trackedDocuments.setObject(document, forKey: uri as NSString)
        trackedDocumentData[uri] = DocumentObject(
            uri: uri,
            documentVersion: 0,
            contentCoordinator: LSPContentCoordinator(documentURI: uri, languageServer: server)
        )
    }

    func document(for uri: DocumentUri) -> CodeFileDocument? {
        let url = URL(filePath: uri)
        return trackedDocuments.object(forKey: url.absolutePath as NSString)
    }

    func removeDocument(for document: CodeFileDocument) {
        guard let uri = document.languageServerURI else { return }
        removeDocument(for: uri)
    }

    func removeDocument(for uri: DocumentUri) {
        trackedDocuments.removeObject(forKey: uri as NSString)
        trackedDocumentData.removeValue(forKey: uri)
    }

    // MARK: - Version Number Tracking

    func incrementVersion(for document: CodeFileDocument) -> Int {
        guard let uri = document.languageServerURI else { return 0 }
        return incrementVersion(for: uri)
    }

    func incrementVersion(for uri: DocumentUri) -> Int {
        trackedDocumentData[uri]?.documentVersion += 1
        return trackedDocumentData[uri]?.documentVersion ?? 0
    }

    func documentVersion(for document: CodeFileDocument) -> Int? {
        guard let uri = document.languageServerURI else { return nil }
        return documentVersion(for: uri)
    }

    func documentVersion(for uri: DocumentUri) -> Int? {
        return trackedDocumentData[uri]?.documentVersion
    }

    // MARK: - Content Coordinator

    func contentCoordinator(for document: CodeFileDocument) -> LSPContentCoordinator? {
        guard let uri = document.languageServerURI else { return nil }
        return contentCoordinator(for: uri)
    }

    func contentCoordinator(for uri: DocumentUri) -> LSPContentCoordinator? {
        trackedDocumentData[uri]?.contentCoordinator
    }
}
