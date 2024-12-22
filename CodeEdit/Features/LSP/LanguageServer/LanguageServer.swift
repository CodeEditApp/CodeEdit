//
//  LanguageServer.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import JSONRPC
import Foundation
import LanguageClient
import LanguageServerProtocol
import OSLog

class LanguageServer {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "LanguageServer")
    let logger: Logger

    /// Identifies which language the server belongs to
    let languageId: LanguageIdentifier
    /// Holds information about the language server binary
    let binary: LanguageServerBinary
    /// A cache to hold responses from the server, to minimize duplicate server requests
    let lspCache = LSPCache()

    /// Tracks documents and their associated objects.
    /// Use this property when adding new objects that need to track file data, or have a state associated with the
    /// language server and a document. For example, the content coordinator.
    let openFiles: LanguageServerFileMap

    /// Maps the language server's highlight config to one CodeEdit can read. See ``SemanticTokenMap``.
    let highlightMap: SemanticTokenMap?

    /// The configuration options this server supports.
    var serverCapabilities: ServerCapabilities

    /// An instance of a language server, that may or may not be initialized
    private(set) var lspInstance: InitializingServer
    /// The path to the root of the project
    private(set) var rootPath: URL

    init(
        languageId: LanguageIdentifier,
        binary: LanguageServerBinary,
        lspInstance: InitializingServer,
        serverCapabilities: ServerCapabilities,
        rootPath: URL
    ) {
        self.languageId = languageId
        self.binary = binary
        self.lspInstance = lspInstance
        self.serverCapabilities = serverCapabilities
        self.rootPath = rootPath
        self.openFiles = LanguageServerFileMap()
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "",
            category: "LanguageServer.\(languageId.rawValue)"
        )
        if let semanticTokensProvider = serverCapabilities.semanticTokensProvider {
            self.highlightMap = SemanticTokenMap(semanticCapability: semanticTokensProvider)
        } else {
            self.highlightMap = nil // Server doesn't support semantic highlights
        }
    }

    /// Creates and initializes a language server.
    /// - Parameters:
    ///   - languageId: The id of the language to create.
    ///   - binary: The binary where the language server is stored.
    ///   - workspacePath: The path of the workspace being opened.
    /// - Returns: An initialized language server.
    static func createServer(
        for languageId: LanguageIdentifier,
        with binary: LanguageServerBinary,
        workspacePath: String
    ) async throws -> LanguageServer {
        let executionParams = Process.ExecutionParameters(
            path: binary.execPath,
            arguments: binary.args,
            environment: binary.env
        )

        let server = InitializingServer(
            server: try makeLocalServerConnection(languageId: languageId, executionParams: executionParams),
            initializeParamsProvider: getInitParams(workspacePath: workspacePath)
        )
        let capabilities = try await server.initializeIfNeeded()
        return LanguageServer(
            languageId: languageId,
            binary: binary,
            lspInstance: server,
            serverCapabilities: capabilities,
            rootPath: URL(filePath: workspacePath)
        )
    }

    // MARK: - Make Local Server Connection

    /// Creates a data channel for sending and receiving data with an LSP.
    /// - Parameters:
    ///   - languageId: The ID of the language to create the channel for.
    ///   - executionParams: The parameters for executing the local process.
    /// - Returns: A new connection to the language server.
    static func makeLocalServerConnection(
        languageId: LanguageIdentifier,
        executionParams: Process.ExecutionParameters
    ) throws -> JSONRPCServerConnection {
        do {
            let channel = try DataChannel.localProcessChannel(
                parameters: executionParams,
                terminationHandler: {
                    logger.debug("Terminated data channel for \(languageId.rawValue)")
                }
            )
            return JSONRPCServerConnection(dataChannel: channel)
        } catch {
            logger.warning("Failed to initialize data channel for \(languageId.rawValue)")
            throw error
        }
    }

    // MARK: - Get Init Params

    // swiftlint:disable function_body_length
    static func getInitParams(workspacePath: String) -> InitializingServer.InitializeParamsProvider {
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
                ),
                // swiftlint:disable:next line_length
                // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#semanticTokensClientCapabilities
                semanticTokens: SemanticTokensClientCapabilities(
                    dynamicRegistration: false,
                    requests: .init(range: true, delta: true),
                    tokenTypes: SemanticTokenTypes.allStrings,
                    tokenModifiers: SemanticTokenModifiers.allStrings,
                    formats: [.relative],
                    overlappingTokenSupport: true,
                    multilineTokenSupport: true,
                    serverCancelSupport: true,
                    augmentsSyntaxTokens: true
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
            let workspaceCapabilities = ClientCapabilities.Workspace(
                applyEdit: true,
                workspaceEdit: nil,
                didChangeConfiguration: DidChangeConfigurationClientCapabilities(dynamicRegistration: true),
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

            let windowClientCapabilities = WindowClientCapabilities(
                workDoneProgress: true,
                showMessage: ShowMessageRequestClientCapabilities(
                    messageActionItem: ShowMessageRequestClientCapabilities.MessageActionItemCapabilities(
                        additionalPropertiesSupport: true
                    )
                ),
                showDocument: ShowDocumentClientCapabilities(
                    support: true
                )
            )

            // All Client Capabilities
            let capabilities = ClientCapabilities(
                workspace: workspaceCapabilities,
                textDocument: textDocumentCapabilities,
                window: windowClientCapabilities,
                general: nil,
                experimental: nil
            )
             return InitializeParams(
                processId: nil,
                locale: nil,
                rootPath: nil,
                rootUri: workspacePath,
                initializationOptions: [],
                capabilities: capabilities,
                trace: nil,
                workspaceFolders: nil
             )
        }
        return provider
        // swiftlint:enable function_body_length
    }

    /// Shuts down the language server and exits it.
    public func shutdown() async throws {
        self.logger.info("Shutting down language server")
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
