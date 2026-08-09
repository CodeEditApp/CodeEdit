//
//  LSPServiceDocumentObjectsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

@testable import CELSP
import XCTest
import CodeEditDocument
import CodeEditSettings
@testable import CodeEdit

@MainActor
final class LSPServiceDocumentObjectsTests: XCTestCase {
    private func makeService() -> LSPService { LSPService(settingsReader: SnapshotSettingsReader([:])) }

    private func makeDocument(path: String) throws -> CodeFileDocument {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "lsp-objs-\(UUID().uuidString)-\(path)")
        try Data("x".utf8).write(to: url)
        return try CodeFileDocument(contentsOf: url, ofType: "public.swift-source")
    }

    func testSameURIReturnsSameInstance() throws {
        let service = makeService()
        let doc = try makeDocument(path: "a.swift")
        let first = service.languageServerObjects(for: doc)
        let second = service.languageServerObjects(for: doc)
        XCTAssertTrue(first.textCoordinator === second.textCoordinator)
    }

    func testDifferentURIsReturnDistinctInstances() throws {
        let service = makeService()
        let docA = try makeDocument(path: "a.swift")
        let docB = try makeDocument(path: "b.swift")
        let objectsA = service.languageServerObjects(for: docA)
        let objectsB = service.languageServerObjects(for: docB)
        XCTAssertFalse(objectsA.textCoordinator === objectsB.textCoordinator)
    }

    func testRemoveDropsStoredInstance() throws {
        let service = makeService()
        let doc = try makeDocument(path: "a.swift")
        let first = service.languageServerObjects(for: doc)
        service.removeLanguageServerObjects(for: doc.languageServerURI!)
        let afterRemove = service.languageServerObjects(for: doc)
        XCTAssertFalse(first.textCoordinator === afterRemove.textCoordinator)
    }
}
