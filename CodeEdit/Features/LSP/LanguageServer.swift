//
//  LanguageServer.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import JSONRPC
import LanguageClient
import LanguageServerProtocol

// TODO: ADD ACTIVATION EVENTS

struct LanguageServer {
    let languageId: LanguageIdentifier
    let binary: LanguageServerBinary

    // TODO: REMOVE
    var trackedDocuments: [String: TextDocumentItem] = [:]
    var lspCache: LSPCache = LSPCache()

    private(set) var lspInstance: InitializingServer
    private(set) var rootPath: URL

    static func createServer(
        for languageId: LanguageIdentifier,
        with binary: LanguageServerBinary,
        rootPath: URL,
        workspaceFolders: [WorkspaceFolder]?
    ) throws -> Self {
        let executionParams = Process.ExecutionParameters(
            path: binary.execPath,
            arguments: binary.args,
            environment: binary.env
        )

        var channel: DataChannel?
        do {
            channel = try DataChannel.localProcessChannel(
                parameters: executionParams,
                terminationHandler: {
                    print("Terminated \(languageId)")
                }
            )
        } catch {
//            logger.error("Failed to start server for language \(languageId.rawValue)")
            throw error
        }
        guard let channel = channel else {
            throw NSError(
                domain: "LanguageClient",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to start server for language \(languageId.rawValue)"]
            )
        }

        let localServer = LanguageServerProtocol.JSONRPCServerConnection(dataChannel: channel)
        let server = InitializingServer(
            server: localServer,
            initializeParamsProvider: getInitParams(projectURL: rootPath)
        )
        return LanguageServer(languageId: languageId, binary: binary, lspInstance: server, rootPath: rootPath)
    }

    // swiftlint:disable function_body_length line_length
    private static func getInitParams(projectURL: URL) -> InitializingServer.InitializeParamsProvider {
        let provider: InitializingServer.InitializeParamsProvider = {
            // Text Document Capabilities
            let textDocumentCapabilities = TextDocumentClientCapabilities(
                completion: CompletionClientCapabilities(
                    dynamicRegistration: true,
                    completionItem: CompletionClientCapabilities.CompletionItem(
                        snippetSupport: true,
                        commitCharactersSupport: true,
                        documentationFormat: [MarkupKind.plaintext],
                        deprecatedSupport: true,
                        preselectSupport: true,
                        tagSupport: ValueSet(valueSet: [CompletionItemTag.deprecated]),
                        insertReplaceSupport: true,
                        resolveSupport: CompletionClientCapabilities.CompletionItem.ResolveSupport(
                            properties: ["documentation", "details"]
                        ),
                        insertTextModeSupport: ValueSet(valueSet: [InsertTextMode.adjustIndentation]),
                        labelDetailsSupport: true
                    ),
                    completionItemKind: ValueSet(valueSet: [CompletionItemKind.text, CompletionItemKind.method]),
                    contextSupport: true,
                    insertTextMode: InsertTextMode.asIs,
                    completionList: CompletionClientCapabilities.CompletionList(
                        itemDefaults: ["default1", "default2"]
                    )
                )
            )

            // Workspace File Operations Capabilities
            let fileOperations = ClientCapabilities.Workspace.FileOperations(
                dynamicRegistration: true,
                didCreate: true,
                willCreate: true,
                didRename: true,
                willRename: true,
                didDelete: true,
                willDelete: true
            )

            // Workspace Capabilities
            // TODO: ADD inlineValue?: InlineValueWorkspaceClientCapabilities;inlayHint?: InlayHintWorkspaceClientCapabilities; diagnostics?: DiagnosticWorkspaceClientCapabilities;
            let workspaceCapabilities = ClientCapabilities.Workspace(
                applyEdit: true,
                workspaceEdit: nil,
                didChangeConfiguration: DidChangeConfigurationClientCapabilities(dynamicRegistration: true),
                // TODO: NEED TO ADD https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didChangeWatchedFiles `relativePatternSupport` VARIABLE
                didChangeWatchedFiles: DidChangeWatchedFilesClientCapabilities(dynamicRegistration: true),
                symbol: WorkspaceSymbolClientCapabilities(
                    dynamicRegistration: true,
                    symbolKind: nil,
                    tagSupport: nil,
                    resolveSupport: []
                ),
                executeCommand: nil,
                workspaceFolders: true,
                configuration: true,
                semanticTokens: nil,
                codeLens: nil,
                fileOperations: fileOperations
            )

            // All Client Capabilities
            let capabilities = ClientCapabilities(
                workspace: workspaceCapabilities,
                textDocument: textDocumentCapabilities,
                window: nil,
                general: nil,
                experimental: nil
            )
             return InitializeParams(
                processId: nil,
                locale: nil,
                rootPath: nil,
                rootUri: projectURL.absoluteString,
                initializationOptions: [],
                capabilities: capabilities,
                trace: nil,
                workspaceFolders: nil
             )
        }
        return provider
        // swiftlint:enable function_body_length line_length
    }

    /// Initializes the language server if it hasn't been initialized already.
    public func initialize() async throws {
        // TODO: CATCH ERROR HERE, LOG ERROR OR SUCCESS
        // InitializationResponse is not returned because it is automatically stored inside `lspInstance`
        _ = try await lspInstance.initializeIfNeeded()
    }

    /// Shuts down the language server and exits it.
    public func shutdown() async throws {
        try await lspInstance.shutdownAndExit()
    }
}

/// Represents a language server binary.
struct LanguageServerBinary: Codable {
    /// The path to the language server binary.
    let execPath: String
    /// The arguments to pass to the language server binary.
    let args: [String]
    /// The environment variables to pass to the language server binary.
    let env: [String: String]?
}

enum LSPError: Error {
    case binaryNotFound
}
