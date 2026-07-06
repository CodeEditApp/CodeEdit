//
//  DocumentRegistryTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import XCTest
import Combine
import CodeEditCore
@testable import CodeEdit

final class DocumentRegistryTests: XCTestCase {
    private func makeFile(_ path: String = "/tmp/reg-\(UUID().uuidString).swift") -> CEWorkspaceFile {
        CEWorkspaceFile(url: URL(filePath: path))
    }

    func testSetAndGetRoundTrip() {
        let registry = DocumentRegistry()
        let file = makeFile()
        let doc = CodeFileDocument()
        registry.setDocument(doc, for: file)
        XCTAssertIdentical(registry.document(for: file), doc)
    }

    func testSetNilClears() {
        let registry = DocumentRegistry()
        let file = makeFile()
        registry.setDocument(CodeFileDocument(), for: file)
        registry.setDocument(nil, for: file)
        XCTAssertNil(registry.document(for: file))
    }

    func testUnknownFileReturnsNil() {
        let registry = DocumentRegistry()
        XCTAssertNil(registry.document(for: makeFile()))
    }

    func testPublisherEmitsOnSet() {
        let registry = DocumentRegistry()
        let file = makeFile()
        var received: [Bool] = []  // whether each emission was non-nil
        var cancellables = Set<AnyCancellable>()
        registry.documentPublisher(for: file)
            .sink { received.append($0 != nil) }
            .store(in: &cancellables)

        let doc = CodeFileDocument()
        registry.setDocument(doc, for: file)
        registry.setDocument(nil, for: file)

        XCTAssertEqual(received, [true, false])
    }

    func testStorageIsWeak() {
        let registry = DocumentRegistry()
        let file = makeFile()
        autoreleasepool {
            let doc = CodeFileDocument()
            registry.setDocument(doc, for: file)
            XCTAssertNotNil(registry.document(for: file))
        }
        // No strong owner remains → the weak ref must be nil.
        XCTAssertNil(registry.document(for: file), "registry must not retain the document")
    }
}
