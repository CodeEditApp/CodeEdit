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
import CodeEditLanguages

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
///
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
///
/// ## Completion Example
///
/// ```swift
/// func testCompletion() async throws {
///     do {
///         guard var languageClient = self.languageClient(for: .python) else {
///             print("Failed to get client")
///             throw ServerManagerError.languageClientNotFound
///         }
///
///         let testFilePathStr = ""
///         let testFileURL = URL(fileURLWithPath: testFilePathStr)
///
///         // Tell server we opened a document
///         _ = await languageClient.addDocument(testFileURL)
///
///         // Completion example
///         let textPosition = Position(line: 32, character: 18)  // Lines and characters start at 0
///         let completions = try await languageClient.requestCompletion(
///             document: testFileURL.absoluteString,
///             position: textPosition
///         )
///         switch completions {
///         case .optionA(let completionItems):
///             // Handle the case where completions is an array of CompletionItem
///             print("\n*******\nCompletion Items:\n*******\n")
///             for item in completionItems {
///                 let textEdits = LSPCompletionItemsUtil.getCompletionItemEdits(
///                     startPosition: textPosition,
///                     item: item
///                 )
///                 for edit in textEdits {
///                     print(edit)
///                 }
///             }
///
///         case .optionB(let completionList):
///             // Handle the case where completions is a CompletionList
///             print("\n*******\nCompletion Items:\n*******\n")
///             for item in completionList.items {
///                 let textEdits = LSPCompletionItemsUtil.getCompletionItemEdits(
///                     startPosition: textPosition,
///                     item: item
///                 )
///                 for edit in textEdits {
///                     print(edit)
///                 }
///             }
///
///             print(completionList.items[0])
///
///         case .none:
///             print("No completions found")
///         }
///
///         // Close the document
///         _ = await languageClient.closeDocument(testFilePathStr)
///     } catch {
///         print(error)
///     }
/// }
/// ```
@MainActor
final class LSPService: ObservableObject {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "LSPService")

    struct ClientKey: Hashable, Equatable {
        let languageId: LanguageIdentifier
        let workspacePath: String

        init(_ languageId: LanguageIdentifier, _ workspacePath: String) {
            self.languageId = languageId
            self.workspacePath = workspacePath
        }
    }

    /// Holds the active language clients
    var languageClients: [ClientKey: LanguageServer] = [:]
    /// Holds the language server configurations for all the installed language servers
    var languageConfigs: [LanguageIdentifier: LanguageServerBinary] = [:]
    /// Holds all the event listeners for each active language client
    var eventListeningTasks: [ClientKey: Task<Void, Never>] = [:]

    @AppSettings(\.developerSettings.lspBinaries)
    var lspBinaries

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

        NotificationCenter.default.addObserver(
            forName: CodeFileDocument.didOpenNotification,
            object: nil,
            queue: .main
        ) { notification in
            MainActor.assumeIsolated {
                guard let document = notification.object as? CodeFileDocument else { return }
                self.openDocument(document)
            }
        }

        NotificationCenter.default.addObserver(
            forName: CodeFileDocument.didCloseNotification,
            object: nil,
            queue: .main
        ) { notification in
            MainActor.assumeIsolated {
                guard let url = notification.object as? URL else { return }
                self.closeDocument(url)
            }
        }
    }

    /// Gets the language server for the specified language and workspace.
    func server(for languageId: LanguageIdentifier, workspacePath: String) -> InitializingServer? {
        return languageClients[ClientKey(languageId, workspacePath)]?.lspInstance
    }

    /// Gets the language client for the specified language
    func languageClient(for languageId: LanguageIdentifier, workspacePath: String) -> LanguageServer? {
        return languageClients[ClientKey(languageId, workspacePath)]
    }

    /// Given a language and workspace path, will attempt to start the language server
    /// - Parameters:
    ///   - languageId: The ID of the language server to start.
    ///   - workspacePath: The workspace this language server is being used in.
    /// - Returns: The new language server.
    func startServer(
        for languageId: LanguageIdentifier,
        workspacePath: String
    ) async throws -> LanguageServer {
        guard let serverBinary = languageConfigs[languageId] else {
            logger.error("Couldn't find language sever binary for \(languageId.rawValue)")
            throw LSPError.binaryNotFound
        }

        logger.info("Starting \(languageId.rawValue) language server")
        let server = try await LanguageServer.createServer(
            for: languageId,
            with: serverBinary,
            workspacePath: workspacePath
        )
        languageClients[ClientKey(languageId, workspacePath)] = server
        logger.info("Successfully started \(languageId.rawValue) language server")

        self.startListeningToEvents(for: ClientKey(languageId, workspacePath))
        return server
    }

    /// Notify all relevant language clients that a document was opened.
    /// - Note: Must be invoked after the contents of the file are available.
    /// - Parameter document: The code document that was opened.
    func openDocument(_ document: CodeFileDocument) {
        guard let workspace = document.findWorkspace(),
              let workspacePath = workspace.fileURL?.absoluteURL.path(),
              let lspLanguage = document.getLanguage().lspLanguage else {
            return
        }
        Task {
            let languageServer: LanguageServer
            do {
                if let server = self.languageClients[ClientKey(lspLanguage, workspacePath)] {
                    languageServer = server
                } else {
                    languageServer = try await self.startServer(for: lspLanguage, workspacePath: workspacePath)
                }
            } catch {
                // swiftlint:disable:next line_length
                self.logger.error("Failed to find/start server for language: \(lspLanguage.rawValue), workspace: \(workspacePath, privacy: .private)")
                return
            }
            do {
                try await languageServer.openDocument(document)
            } catch {
                let uri = await document.languageServerURI
                // swiftlint:disable:next line_length
                self.logger.error("Failed to close document: \(uri ?? "<NO URI>", privacy: .private), language: \(lspLanguage.rawValue). Error \(error)")
            }
        }
    }

    /// Notify all relevant language clients that a document was closed.
    /// - Parameter url: The url of the document that was closed
    func closeDocument(_ url: URL) {
        guard let languageClient = languageClients.first(where: {
                  $0.value.openFiles.document(for: url.absolutePath) != nil
              })?.value else {
            return
        }
        Task {
            do {
                try await languageClient.closeDocument(url.absolutePath)
            } catch {
                // swiftlint:disable:next line_length
                logger.error("Failed to close document: \(url.absolutePath, privacy: .private), language: \(languageClient.languageId.rawValue). Error \(error)")
            }
        }
    }

    /// Close all language clients for a workspace.
    ///
    /// This is intentionally synchronous so we can exit from the workspace document's ``WorkspaceDocument/close()``
    /// method ASAP.
    ///
    /// Errors thrown in this method are logged and otherwise not handled.
    /// - Parameter workspacePath: The path of the workspace.
    func closeWorkspace(_ workspacePath: String) {
        Task {
            let clientKeys = self.languageClients.filter({ $0.key.workspacePath == workspacePath })
            for (key, languageClient) in clientKeys {
                do {
                    try await languageClient.shutdown()
                } catch {
                    logger.error("Failed to shutdown \(key.languageId.rawValue) Language Server: Error \(error)")
                }
            }
            for (key, _) in clientKeys {
                self.languageClients.removeValue(forKey: key)
            }
        }
    }

    /// Attempts to stop a running language server. Throws an error if the server is not found
    /// or if the language server throws an error while trying to shutdown.
    /// - Parameters:
    ///   - languageId: The ID of the language server to stop.
    ///   - workspacePath: The path of the workspace to stop the language server for.
    func stopServer(forLanguage languageId: LanguageIdentifier, workspacePath: String) async throws {
        guard let server = server(for: languageId, workspacePath: workspacePath) else {
            logger.error("Server not found for language \(languageId.rawValue) during stop operation")
            throw ServerManagerError.serverNotFound
        }
        do {
            try await server.shutdownAndExit()
        } catch {
            logger.error("Failed to stop server for language \(languageId.rawValue): \(error.localizedDescription)")
            throw error
        }
        languageClients.removeValue(forKey: ClientKey(languageId, workspacePath))
        logger.info("Server stopped for language \(languageId.rawValue)")

        stopListeningToEvents(for: ClientKey(languageId, workspacePath))
    }

    /// Goes through all active language servers and attempts to shut them down.
    func stopAllServers() async {
        await withThrowingTaskGroup(of: Void.self) { group in
            for (key, server) in languageClients {
                group.addTask {
                    do {
                        try await server.shutdown()
                    } catch {
                        self.logger.error("Shutting down \(key.languageId.rawValue): Error \(error)")
                        throw error
                    }
                }
            }
        }
        languageClients.removeAll()
        eventListeningTasks.forEach { (_, value) in
            value.cancel()
        }
        eventListeningTasks.removeAll()
    }
}

// MARK: - Errors

enum ServerManagerError: Error {
    case serverNotFound
    case serverStartFailed
    case serverStopFailed
    case languageClientNotFound
}
