//
//  LanguageServer+DocumentTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 9/9/24.
//

import XCTest
import CodeEditTextView
import CodeEditSourceEditor
import LanguageClient
import LanguageServerProtocol

@testable import CodeEdit

final class LanguageServerDocumentTests: XCTestCase {
    // Test opening documents in CodeEdit triggers creating a language server,
    // further opened documents don't create new servers

    var tempTestDir: URL!

    override func setUp() {
        continueAfterFailure = false
        do {
            let tempDir = FileManager.default.temporaryDirectory.appending(
                path: "codeedit-lsp-tests"
            )
            // Clean up first.
            if FileManager.default.fileExists(atPath: tempDir.absoluteURL.path()) {
                try FileManager.default.removeItem(at: tempDir)
            }
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

    func openCodeFile(
        for server: LanguageServer,
        connection: BufferingServerConnection,
        file: CEWorkspaceFile,
        syncOption: TwoTypeOption<TextDocumentSyncOptions, TextDocumentSyncKind>?
    ) async throws -> CodeFileDocument {
        let codeFile = try await CodeFileDocument(
            for: file.url,
            withContentsOf: file.url,
            ofType: "public.swift-source"
        )

        // This is usually sent from the LSPService
        try await server.openDocument(codeFile)

        await waitForClientEventCount(
            3,
            connection: connection,
            description: "Initialized (2) and opened (1) notification count"
        )

        // Set up full content changes
        server.serverCapabilities = ServerCapabilities()
        server.serverCapabilities.textDocumentSync = syncOption

        return codeFile
    }

    func waitForClientEventCount(_ count: Int, connection: BufferingServerConnection, description: String) async {
        let expectation = expectation(description: description)

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fulfillment(of: [expectation], timeout: 2)
            }
            group.addTask {
                for await events in connection.clientEventSequence where events.0.count + events.1.count == count {
                    expectation.fulfill()
                    return
                }
            }
        }
    }

    @MainActor
    func testOpenCloseFileNotifications() async throws {
        // Set up test server
        let (connection, server) = try await makeTestServer()

        // This service should receive the didOpen/didClose notifications
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
        let codeFile = try CodeFileDocument(
            for: file.url,
            withContentsOf: file.url,
            ofType: "public.swift-source"
        )
        file.fileDocument = codeFile
        CodeEditDocumentController.shared.addDocument(codeFile)

        await waitForClientEventCount(3, connection: connection, description: "Pre-close event count")

        // This should then trigger a documentDidClose event
        codeFile.close()

        await waitForClientEventCount(4, connection: connection, description: "Post-close event count")

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

    /// Assert the changed contents received by the buffered connection
    func assertExpectedContentChanges(connection: BufferingServerConnection, changes: [String]) {
        var foundChangeContents: [String] = []

        for notification in connection.clientNotifications {
            switch notification {
            case let .textDocumentDidChange(params):
                foundChangeContents.append(contentsOf: params.contentChanges.map { event in
                    event.text
                })
            default:
                continue
            }
        }

        XCTAssertEqual(changes, foundChangeContents)
    }

    @MainActor
    func testDocumentEditNotificationsFullChanges() async throws {
        // Set up a workspace in the temp directory
        let (_, fileManager) = try makeTestWorkspace()

        // Make our example file
        try fileManager.addFile(fileName: "example", toFile: fileManager.workspaceItem, useExtension: "swift")
        guard let file = fileManager.childrenOfFile(fileManager.workspaceItem)?.first else {
            XCTFail("No File")
            return
        }

        // Need to test both definitions for server capabilities
        let syncOptions: [TwoTypeOption<TextDocumentSyncOptions, TextDocumentSyncKind>] = [
            .optionA(.init(change: .full)),
            .optionB(.full)
        ]

        for option in syncOptions {
            // Set up test server
            let (connection, server) = try await makeTestServer()
            // Create a CodeFileDocument to test with, attach it to the workspace and file
            let codeFile = try await openCodeFile(for: server, connection: connection, file: file, syncOption: option)
            XCTAssertNotNil(server.openFiles.contentCoordinator(for: codeFile))
            server.openFiles.contentCoordinator(for: codeFile)?.setUpUpdatesTask()
            codeFile.content?.replaceString(in: .zero, with: #"func testFunction() -> String { "Hello " }"#)

            let textView = TextView(string: "")
            textView.setTextStorage(codeFile.content!)
            textView.delegate = server.openFiles.contentCoordinator(for: codeFile)

            textView.replaceCharacters(in: NSRange(location: 39, length: 0), with: "Worlld")
            textView.replaceCharacters(in: NSRange(location: 39, length: 6), with: "")
            textView.replaceCharacters(in: NSRange(location: 39, length: 0), with: "World")

            // Added one notification
            await waitForClientEventCount(4, connection: connection, description: "Edited notification count")

            // Make sure our text view is intact
            XCTAssertEqual(textView.string, #"func testFunction() -> String { "Hello World" }"#)
            XCTAssertEqual(
                [
                    ClientNotification.Method.initialized,
                    ClientNotification.Method.textDocumentDidOpen,
                    ClientNotification.Method.textDocumentDidChange
                ],
                connection.clientNotifications.map { $0.method }
            )

            // Expect only one change due to throttling.
            assertExpectedContentChanges(
                connection: connection,
                changes: [#"func testFunction() -> String { "Hello World" }"#]
            )
        }
    }

    @MainActor
    func testDocumentEditNotificationsIncrementalChanges() async throws {
        // Set up test server
        let (_, _) = try await makeTestServer()

        // Set up a workspace in the temp directory
        let (_, fileManager) = try makeTestWorkspace()

        // Make our example file
        try fileManager.addFile(fileName: "example", toFile: fileManager.workspaceItem, useExtension: "swift")
        guard let file = fileManager.childrenOfFile(fileManager.workspaceItem)?.first else {
            XCTFail("No File")
            return
        }

        let syncOptions: [TwoTypeOption<TextDocumentSyncOptions, TextDocumentSyncKind>] = [
            .optionA(.init(change: .incremental)),
            .optionB(.incremental)
        ]

        for option in syncOptions {
            // Set up test server
            let (connection, server) = try await makeTestServer()
            let codeFile = try await openCodeFile(for: server, connection: connection, file: file, syncOption: option)

            XCTAssertNotNil(server.openFiles.contentCoordinator(for: codeFile))
            server.openFiles.contentCoordinator(for: codeFile)?.setUpUpdatesTask()
            codeFile.content?.replaceString(in: .zero, with: #"func testFunction() -> String { "Hello " }"#)

            let textView = TextView(string: "")
            textView.setTextStorage(codeFile.content!)
            textView.delegate = server.openFiles.contentCoordinator(for: codeFile)
            textView.replaceCharacters(in: NSRange(location: 39, length: 0), with: "Worlld")
            textView.replaceCharacters(in: NSRange(location: 39, length: 6), with: "")
            textView.replaceCharacters(in: NSRange(location: 39, length: 0), with: "World")

            // Throttling means we should receive one edited notification + init notification + didOpen + init request
            await waitForClientEventCount(4, connection: connection, description: "Edited notification count")

            // Make sure our text view is intact
            XCTAssertEqual(textView.string, #"func testFunction() -> String { "Hello World" }"#)
            XCTAssertEqual(
                [
                    ClientNotification.Method.initialized,
                    ClientNotification.Method.textDocumentDidOpen,
                    ClientNotification.Method.textDocumentDidChange
                ],
                connection.clientNotifications.map { $0.method }
            )

            // Expect three content changes.
            assertExpectedContentChanges(
                connection: connection,
                changes: ["Worlld", "", "World"]
            )
        }
    }
}
