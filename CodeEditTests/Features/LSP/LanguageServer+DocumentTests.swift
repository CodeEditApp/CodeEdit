//
//  LanguageServer+DocumentTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 9/9/24.
//

import XCTest
import LanguageClient
import LanguageServerProtocol

@testable import CodeEdit

final class LanguageServerDocumentTests: XCTestCase {
    // Test opening documents in CodeEdit triggers creating a language server,
    // further opened documents don't create new servers

    var tempTestDir: URL!

    override func setUp() {
        do {
            let tempDir = FileManager.default.temporaryDirectory.appending(
                path: "codeedit-lsp-tests"
            )
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            tempTestDir = tempDir
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        do {
            try FileManager.default.removeItem(at: tempTestDir)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func makeTestServer() async throws -> (connection: BufferingServerConnection, server: LanguageServer) {
        let bufferingConnection = BufferingServerConnection()
        var capabilities = ServerCapabilities()
        capabilities.textDocumentSync = .optionA(
            TextDocumentSyncOptions(
                openClose: true,
                change: .incremental,
                willSave: true,
                willSaveWaitUntil: false,
                save: nil
            )
        )
        let server = LanguageServer(
            languageId: .swift,
            binary: .init(execPath: "", args: [], env: nil),
            lspInstance: InitializingServer(
                server: bufferingConnection,
                initializeParamsProvider: LanguageServer.getInitParams(workspacePath: tempTestDir.path())
            ),
            serverCapabilities: capabilities,
            rootPath: tempTestDir
        )
        _ = try await server.lspInstance.initializeIfNeeded()
        return (connection: bufferingConnection, server: server)
    }

    func makeTestWorkspace() throws -> (WorkspaceDocument, CEWorkspaceFileManager) {
        let workspace = WorkspaceDocument()
        try workspace.read(from: tempTestDir, ofType: "")
        guard let fileManager = workspace.workspaceFileManager else {
            XCTFail("No File Manager")
            fatalError("No File Manager") // never runs
        }
        return (workspace, fileManager)
    }

    @MainActor
    func testOpenFileInWorkspaceNotifiesLSP() async throws {
        // Set up test server
        let (connection, server) = try await makeTestServer()

        let lspService = ServiceContainer.resolve(.singleton, LSPService.self)
        await MainActor.run { lspService?.languageClients[.init(.swift, tempTestDir.path() + "/")] = server }

        // Set up workspace
        let (workspace, fileManager) = try makeTestWorkspace()
        CodeEditDocumentController.shared.addDocument(workspace)

        // Add a CEWorkspaceFile
        try fileManager.addFile(fileName: "example", toFile: fileManager.workspaceItem, useExtension: "swift")
        guard let file = fileManager.childrenOfFile(fileManager.workspaceItem)?.first else {
            XCTFail("No File")
            return
        }

        // Create a CodeFileDocument to test with, attach it to the workspace and file
        let contentType = try file.url.resourceValues(forKeys: [.contentTypeKey]).contentType
        let codeFile = try CodeFileDocument(
            for: file.url,
            withContentsOf: file.url,
            ofType: contentType?.identifier ?? ""
        )
        file.fileDocument = codeFile

        // This should trigger a documentDidOpen event
        CodeEditDocumentController.shared.addDocument(codeFile)

        let eventCountExpectation = expectation(description: "Pre-close event count")
        // Wait off the main actor until we've received all the events
        Task.detached {
            while connection.clientNotifications.count + connection.clientRequests.count < 3 {
                try await Task.sleep(for: .milliseconds(10))
            }
            eventCountExpectation.fulfill()
        }

        await fulfillment(of: [eventCountExpectation], timeout: 5)

        // This should then trigger a documentDidClose event
        codeFile.close()

        let eventCloseExpectation = expectation(description: "Post-close event count")
        Task.detached {
            while connection.clientNotifications.count + connection.clientRequests.count < 4 {
                try await Task.sleep(for: .milliseconds(10))
            }
            eventCloseExpectation.fulfill()
        }
        await fulfillment(of: [eventCloseExpectation], timeout: 5.0)

        XCTAssertEqual(
            connection.clientRequests.map { $0.method },
            [
                ClientRequest.Method.initialize,
            ]
        )

        XCTAssertEqual(
            connection.clientNotifications.map { $0.method },
            [
                ClientNotification.Method.initialized,
                ClientNotification.Method.textDocumentDidOpen,
                ClientNotification.Method.textDocumentDidClose
            ]
        )
    }
}
