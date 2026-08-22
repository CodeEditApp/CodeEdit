//
//  LanguageServer+DocumentObjects.swift
//  CodeEditTests
//
//  Created by Khan Winter on 2/12/25.
//

@testable import CELSP
import XCTest
import CodeEditTextView
import CodeEditSourceEditor
import CodeEditLanguages
import LanguageClient
import LanguageServerProtocol

@testable import CodeEdit

@MainActor
final class LanguageServerDocumentObjectsTests: XCTestCase {
    @MainActor
    final class MockDocumentType: @preconcurrency LanguageServerDocument {
        var content: NSTextStorage?
        var languageServerURI: String?
        /// Test-local store (the protocol no longer requires it; `LSPService` owns it in production).
        /// The server's `provideObjects`/`clearObjects` closures are wired to this in `setUp`.
        var languageServerObjects = LanguageServerDocumentObjects<MockDocumentType>()

        init() {
            self.content = NSTextStorage(string: "hello world")
            self.languageServerURI = "/test/file/path"
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
        let document = MockDocumentType()
        self.document = document
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
            logContainer: LanguageServerLogContainer(language: .swift),
            provideObjects: { $0.languageServerObjects },
            clearObjects: { [weak document] _ in document?.languageServerObjects = .init() }
        )
        _ = try await server.lspInstance.initializeIfNeeded()
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
