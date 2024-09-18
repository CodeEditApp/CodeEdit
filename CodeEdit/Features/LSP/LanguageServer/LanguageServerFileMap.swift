//
//  LanguageServerFileMap.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/8/24.
//

import Foundation
import LanguageServerProtocol

class LanguageServerFileMap {
    private var trackedDocuments: NSMapTable<NSString, CodeFileDocument>
    private var trackedDocumentVersions: [String: Int] = [:]

    init() {
        trackedDocuments = NSMapTable<NSString, CodeFileDocument>(valueOptions: [.weakMemory])
    }

    // MARK: - Track & Remove Documents

    func addDocument(_ document: CodeFileDocument) {
        guard let uri = document.languageServerURI else { return }
        trackedDocuments.setObject(document, forKey: uri as NSString)
        trackedDocumentVersions[uri] = 0
    }

    func document(for uri: DocumentUri) -> CodeFileDocument? {
        let url = URL(filePath: uri)
        return trackedDocuments.object(forKey: url.languageServerURI as NSString)
    }

    func removeDocument(for document: CodeFileDocument) {
        guard let uri = document.languageServerURI else { return }
        removeDocument(for: uri)
    }

    func removeDocument(for uri: DocumentUri) {
        trackedDocuments.removeObject(forKey: uri as NSString)
        trackedDocumentVersions.removeValue(forKey: uri)
    }

    // MARK: - Version Number Tracking

    func incrementVersion(for document: CodeFileDocument) -> Int {
        guard let uri = document.languageServerURI else { return 0 }
        return incrementVersion(for: uri)
    }

    func incrementVersion(for uri: DocumentUri) -> Int {
        trackedDocumentVersions[uri] = (trackedDocumentVersions[uri] ?? 0) + 1
        return  trackedDocumentVersions[uri] ?? 0
    }

    func documentVersion(for document: CodeFileDocument) -> Int? {
        guard let uri = document.languageServerURI else { return nil }
        return documentVersion(for: uri)
    }

    func documentVersion(for uri: DocumentUri) -> Int? {
        return trackedDocumentVersions[uri]
    }
}
