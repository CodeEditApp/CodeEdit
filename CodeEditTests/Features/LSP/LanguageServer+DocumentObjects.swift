//
//  LanguageServer+DocumentObjects.swift
//  CodeEditTests
//
//  Created by Khan Winter on 2/12/25.
//

import XCTest
import CodeEditTextView
import CodeEditSourceEditor
import CodeEditLanguages
import LanguageClient
import LanguageServerProtocol

@testable import CodeEdit

final class LanguageServerDocumentObjectsTests: XCTestCase {
    final class MockDocumentType: LanguageServerDocument {
        var content: NSTextStorage?
        var languageServerURI: String?
        var languageServerObjects: LanguageServerDocumentObjects<MockDocumentType>

        init() {
            self.content = NSTextStorage(string: "hello world")
            self.languageServerURI = "/test/file/path"
            self.languageServerObjects = .init()
        }

        func getLanguage() -> CodeLanguage {
            .swift
        }
    }

    typealias LanguageServerType = LanguageServer<MockDocumentType>

    var document: MockDocumentType!
    var server: LanguageServerType!

    // MARK: - Set Up

    override func setUp() async throws {
        var capabilities = ServerCapabilities()
        capabilities.textDocumentSync = .optionA(.init(openClose: true, change: .full))
        capabilities.semanticTokensProvider = .optionA(.init(legend: .init(tokenTypes: [], tokenModifiers: [])))
        server = LanguageServerType(
            languageId: .swift,
            binary: .init(execPath: "", args: [], env: nil),
            lspInstance: InitializingServer(
                server: BufferingServerConnection(),
                initializeParamsProvider: LanguageServerType.getInitParams(workspacePath: "/")
            ),
            lspPid: -1,
            serverCapabilities: capabilities,
            rootPath: URL(fileURLWithPath: ""),
            logContainer: LanguageServerLogContainer(language: .swift)
        )
        _ = try await server.lspInstance.initializeIfNeeded()
        document = MockDocumentType()
    }

    // MARK: - Tests

    func testOpenDocumentRegistersObjects() async throws {
        try await server.openDocument(document)
        XCTAssertNotNil(document.languageServerObjects.highlightProvider)
        XCTAssertNotNil(document.languageServerObjects.textCoordinator)
        XCTAssertNotNil(server.openFiles.document(for: document.languageServerURI ?? ""))
    }

    func testCloseDocumentClearsObjects() async throws {
        guard let languageServerURI = document.languageServerURI else {
            XCTFail("Language server URI missing on a mock object")
            return
        }
        try await server.openDocument(document)
        XCTAssertNotNil(server.openFiles.document(for: languageServerURI))

        try await server.closeDocument(languageServerURI)
        XCTAssertNil(document.languageServerObjects.highlightProvider.languageServer)
        XCTAssertNil(document.languageServerObjects.textCoordinator.languageServer)
    }
}
