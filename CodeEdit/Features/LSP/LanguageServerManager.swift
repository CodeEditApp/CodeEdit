//
//  LanguageServerManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import os.log
import JSONRPC
import Foundation
import LanguageClient
import LanguageServerProtocol

final class LanguageServerManager: ObservableObject {
    private let logger: Logger
    private var languageClients: [LanguageIdentifier: LanguageServer] = [:]
    private var languageConfigs: [LanguageIdentifier: LanguageServerBinary] = [:]

    init() {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "LanguageServerManager")
        self.languageConfigs = loadLSPConfigurations(
            from: Bundle.main.url(forResource: "lspConfigs", withExtension: "json")
        )
    }

    func server(for languageId: LanguageIdentifier) -> InitializingServer? {
        return languageClients[languageId]?.lspInstance
    }

    func languageClient(for languageId: LanguageIdentifier) -> LanguageServer? {
        return languageClients[languageId]
    }

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

        // TODO: BACKGROUND THREAD TO LISTEN TO EVENTS FROM CLIENT
    }

    func testListenEvents() async throws {
//        guard var languageClient = self.languageClient(for: .python) else {
//            print("Failed to get client")
//            exit(1)
//        }
//
//        print("Listening for events...")
//        for await event in languageClient.lspInstance.eventSequence {
//            switch event {
//            case let .request(id: id, request: request):
//                print("Request ID: \(id)")
//
//                switch request {
//                case let .workspaceConfiguration(params, handler):
//                    print("workspaceConfiguration: \(params)")
//                case let .workspaceFolders(handler):
//                    print("workspaceFolders: \(String(describing: handler))")
//                case let .workspaceApplyEdit(params, handler):
//                    print("workspaceApplyEdit: \(params)")
//                case let .clientRegisterCapability(params, handler):
//                    print("clientRegisterCapability: \(params)")
//                case let .clientUnregisterCapability(params, handler):
//                    print("clientUnregisterCapability: \(params)")
//                case let .workspaceCodeLensRefresh(handler):
//                    print("workspaceCodeLensRefresh: \(String(describing: handler))")
//                case let .workspaceSemanticTokenRefresh(handler):
//                    print("workspaceSemanticTokenRefresh: \(String(describing: handler))")
//                case let .windowShowMessageRequest(params, handler):
//                    print("windowShowMessageRequest: \(params)")
//                case let .windowShowDocument(params, handler):
//                    print("windowShowDocument: \(params)")
//                case let .windowWorkDoneProgressCreate(params, handler):
//                    print("windowWorkDoneProgressCreate: \(params)")
//                }
//
//            case let .notification(notification):
//                switch notification {
//                case let .windowLogMessage(params):
//                    print("windowLogMessage \(params.type)\n```\n\(params.message)\n```\n")
//                case let .windowShowMessage(params):
//                    print("windowShowMessage \(params.type)\n```\n\(params.message)\n```\n")
//                case let .textDocumentPublishDiagnostics(params):
//                    print("textDocumentPublishDiagnostics: \(params)")
//                case let .telemetryEvent(params):
//                    print("telemetryEvent: \(params)")
//                case let .protocolCancelRequest(params):
//                    print("protocolCancelRequest: \(params)")
//                case let .protocolProgress(params):
//                    print("protocolProgress: \(params)")
//                case let .protocolLogTrace(params):
//                    print("protocolLogTrace: \(params)")
//                }
//
//            case let .error(error):
//                print("Error from EventStream: \(error)")
//            }
//        }
    }

    func testCompletion() async throws {
        do {
            guard var languageClient = self.languageClient(for: .python) else {
                print("Failed to get client")
                throw ServerManagerError.languageClientNotFound
            }

            let testFilePathStr = "/Users/abe/Documents/Python/FastestFastAPI/main.py"
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
                    let textEdits = getCompletionItemEdits(startPosition: textPosition, item: item)
                    for edit in textEdits {
                        print(edit)
                    }
                }

            case .optionB(let completionList):
                // Handle the case where completions is a CompletionList
                print("\n*******\nCompletion Items:\n*******\n")
                for item in completionList.items {
                    let textEdits = getCompletionItemEdits(startPosition: textPosition, item: item)
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

    func stopServer(for languageId: LanguageIdentifier) async throws {
        guard let server = self.server(for: languageId) else {
            logger.error("Server not found for language \(languageId.rawValue) during stop operation")
            throw ServerManagerError.serverNotFound
        }
        do {
            try await server.shutdownAndExit()
        } catch {
            logger.error("Failed to stop server for language \(languageId.rawValue)")
        }
        languageClients.removeValue(forKey: languageId)
        logger.info("Server stopped for language \(languageId.rawValue)")

        // TODO: STOP BACKGROUND THREAD FOR LISTENING TO EVENTS
    }

    func restartServer(for languageId: LanguageIdentifier) async throws {
//        guard let langServer = languageClients[languageId] else {
//            logger.error("Server not found for language \(languageId.rawValue) during restart operation")
//            throw ServerManagerError.serverNotFound
//        }
        // TODO: RESTART SERVER
    }

    func stopAllServers() async throws {
        for (languageId, server) in languageClients {
            try await server.lspInstance.shutdownAndExit()
            languageClients.removeValue(forKey: languageId)
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
