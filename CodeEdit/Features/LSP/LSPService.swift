//
//  LSPService.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import os.log
import JSONRPC
import Foundation
import LanguageClient
import LanguageServerProtocol

/// `LSPService` is a service class responsible for managing the lifecycle and event handling
/// of Language Server Protocol (LSP) clients within the CodeEdit application. It handles the initialization,
/// communication, and termination of language servers, ensuring that code assistance features
/// such as code completion, diagnostics, and more are available for various programming languages.
///
/// This class uses Swift's concurrency model to manage background tasks and event streams
/// efficiently. Each language server runs in its own asynchronous task, listening for events and
/// handling them as they occur. The `LSPService` class also provides functionality to start
/// and stop individual language servers, as well as to stop all running servers.
///
/// ## Example Usage
/// ```swift
/// @Service var lspService
///
/// try await lspService.startServer(
///    for: .python,
///    projectURL: projectURL,
///    workspaceFolders: workspaceFolders
/// )
/// try await lspService.stopServer(for: .python)
/// ```
final class LSPService: ObservableObject {
    internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "LSPService")

    /// Holds the active language clients
    internal var languageClients: [LanguageIdentifier: LanguageServer] = [:]
    /// Holds the language server configurations for all the installed language servers
    internal var languageConfigs: [LanguageIdentifier: LanguageServerBinary] = [:]
    /// Holds all the event listeners for each active language client
    internal var eventListeningTasks: [LanguageIdentifier: Task<Void, Never>] = [:]

    @AppSettings(\.developerSettings.lspBinaries)
    internal var lspBinaries

    init() {
        // Load the LSP binaries from the developer menu
        for binary in lspBinaries {
            if let language = LanguageIdentifier(rawValue: binary.key) {
                self.languageConfigs[language] = LanguageServerBinary(
                    execPath: binary.value,
                    args: [],
                    env: ProcessInfo.processInfo.environment
                )
            }
        }
    }

    /// Gets the language server for the specified language
    func server(for languageId: LanguageIdentifier) -> InitializingServer? {
        return languageClients[languageId]?.lspInstance
    }

    /// Gets the language client for the specified language
    func languageClient(for languageId: LanguageIdentifier) -> LanguageServer? {
        return languageClients[languageId]
    }

    /// Given a language, will attempt to start the language server
    func startServer(
        for languageId: LanguageIdentifier,
        projectURL: URL,
        workspaceFolders: [WorkspaceFolder]?
    ) async throws {
        guard let serverBinary = languageConfigs[languageId] else {
            logger.error("Couldn't find language sever binary for \(languageId.rawValue)")
            throw LSPError.binaryNotFound
        }

        let server = try LanguageServer.createServer(
            for: languageId,
            with: serverBinary,
            rootPath: projectURL,
            workspaceFolders: workspaceFolders
        )
        languageClients[languageId] = server

        logger.info("Initializing \(languageId.rawValue) language server")
        try await server.initialize()
        logger.info("Successfully initialized \(languageId.rawValue) language server")

        self.startListeningToEvents(for: languageId)
    }

    /// Notify the proper language server that we opened a document.
    func documentWasOpened(for languageId: LanguageIdentifier, file fileURL: URL) async throws -> Bool {
        // TODO: GET FILE TYPE FROM DOCUMENT, USING NEW FILE SOLUTION
        guard var languageClient = self.languageClient(for: .python) else {
            logger.error("Failed to get \(languageId.rawValue) client")
            throw ServerManagerError.languageClientNotFound
        }
        return await languageClient.addDocument(fileURL)
    }

    /// Notify the proper language server that we closed a document so we can stop tracking the file.
    func documentWasClosed(for languageId: LanguageIdentifier, file fileURL: URL) async throws -> Bool {
        // TODO: GET FILE TYPE FROM DOCUMENT, USING NEW FILE SOLUTION
        guard var languageClient = self.languageClient(for: .python) else {
            logger.error("Failed to get \(languageId.rawValue) client")
            throw ServerManagerError.languageClientNotFound
        }
        return await languageClient.closeDocument(fileURL.absoluteString)
    }

    /// NOTE: This function is intended to be removed when the frontend is being developed.
    /// For now this is just for reference of a working example.
    func testCompletion() async throws {
        do {
            guard var languageClient = self.languageClient(for: .python) else {
                print("Failed to get client")
                throw ServerManagerError.languageClientNotFound
            }

            let testFilePathStr = ""
            let testFileURL = URL(fileURLWithPath: testFilePathStr)

            // Tell server we opened a document
            _ = await languageClient.addDocument(testFileURL)

            // Completion example
            let textPosition = Position(line: 32, character: 18)  // Lines and characters start at 0
            let completions = try await languageClient.requestCompletion(
                document: testFileURL.absoluteString,
                position: textPosition
            )
            switch completions {
            case .optionA(let completionItems):
                // Handle the case where completions is an array of CompletionItem
                print("\n*******\nCompletion Items:\n*******\n")
                for item in completionItems {
                    let textEdits = LSPCompletionItemsUtil.getCompletionItemEdits(
                        startPosition: textPosition,
                        item: item
                    )
                    for edit in textEdits {
                        print(edit)
                    }
                }

            case .optionB(let completionList):
                // Handle the case where completions is a CompletionList
                print("\n*******\nCompletion Items:\n*******\n")
                for item in completionList.items {
                    let textEdits = LSPCompletionItemsUtil.getCompletionItemEdits(
                        startPosition: textPosition,
                        item: item
                    )
                    for edit in textEdits {
                        print(edit)
                    }
                }

                print(completionList.items[0])

            case .none:
                print("No completions found")
            }

            // Close the document
            _ = await languageClient.closeDocument(testFilePathStr)
        } catch {
            print(error)
        }
    }

    /// Attempts to stop a running language server. Throws an error if the server is not found
    /// or if the language server throws an error while trying to shutdown.
    func stopServer(for languageId: LanguageIdentifier) async throws {
        guard let server = self.server(for: languageId) else {
            logger.error("Server not found for language \(languageId.rawValue) during stop operation")
            throw ServerManagerError.serverNotFound
        }
        do {
            try await server.shutdownAndExit()
        } catch {
            logger.error("Failed to stop server for language \(languageId.rawValue): \(error.localizedDescription)")
            throw error
        }
        languageClients.removeValue(forKey: languageId)
        logger.info("Server stopped for language \(languageId.rawValue)")

        stopListeningToEvents(for: languageId)
    }

    /// Goes through all active langauge servers and attempts to shut them down.
    func stopAllServers() async throws {
        for languageId in languageClients.keys {
            try await stopServer(for: languageId)
        }
    }
}

// MARK: - Errors

enum ServerManagerError: Error {
    case serverNotFound
    case serverStartFailed
    case serverStopFailed
    case languageClientNotFound
}
