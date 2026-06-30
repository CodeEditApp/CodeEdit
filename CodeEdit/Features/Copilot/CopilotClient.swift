//
//  CopilotClient.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation
import JSONRPC
import LanguageClient
import LanguageServerProtocol
import OSLog

/// A raw JSON-RPC client for the GitHub Copilot language server.
///
/// `LanguageServerProtocol`'s typed enums do not model Copilot's custom requests (`signIn`, `checkStatus`,
/// `textDocument/inlineCompletion`, ...), so this client drives the server with hand-rolled `Codable` types over
/// a ``JSONRPCSession``. The session is created on top of `DataChannel.localProcessChannel(parameters:)`
/// wrapped with LSP header framing via `withMessageFraming()`.
///
/// The client also answers the server-to-client requests that would otherwise stall the server
/// (`workspace/configuration`, `window/workDoneProgress/create`, `window/showDocument`) and forwards the
/// `didChangeStatus/v2` notification to its owner.
final class CopilotClient {
    /// A `{ "success": true }` reply for `window/showDocument`.
    private struct ShowDocumentResult: Codable, Sendable {
        let success: Bool
    }

    /// `{ "settings": {} }` payload for `workspace/didChangeConfiguration`.
    private struct DidChangeConfigurationParams: Codable, Sendable {
        let settings: CopilotEmptyObject
    }

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CopilotClient")

    /// The underlying JSON-RPC session, framed for LSP transport.
    let session: JSONRPCSession
    /// The language-server process.
    let process: Process

    private var eventTask: Task<Void, Never>?

    /// Forwards `didChangeStatus/v2` notifications to the owner (the ``CopilotService``).
    var onStatusChange: (@Sendable (CopilotDidChangeStatusParams) -> Void)?

    init(session: JSONRPCSession, process: Process) {
        self.session = session
        self.process = process
    }

    deinit {
        eventTask?.cancel()
    }

    // MARK: - Process Launch

    /// Spawns the Copilot language server as a local subprocess and wires up a framed JSON-RPC session.
    /// - Parameters:
    ///   - binaryPath: Absolute path to the `copilot-language-server` executable.
    ///   - arguments: Process arguments. Defaults to `["--stdio"]`.
    ///   - environment: Environment variables for the process.
    ///   - terminationHandler: Invoked when the process terminates unexpectedly.
    /// - Returns: A connected, but not yet initialized, client.
    static func launch(
        binaryPath: String,
        arguments: [String] = ["--stdio"],
        environment: [String: String],
        terminationHandler: @escaping @Sendable () -> Void
    ) throws -> CopilotClient {
        let params = Process.ExecutionParameters(
            path: binaryPath,
            arguments: arguments,
            environment: environment
        )
        let (channel, process) = try DataChannel.localProcessChannel(
            parameters: params,
            terminationHandler: terminationHandler
        )
        let session = JSONRPCSession(channel: channel.withMessageFraming())
        let client = CopilotClient(session: session, process: process)
        client.startListening()
        return client
    }

    // MARK: - Server To Client Traffic

    /// Begins consuming server-to-client requests and notifications so the server does not stall.
    private func startListening() {
        eventTask = Task { [weak self] in
            guard let session = self?.session else { return }
            let sequence = await session.eventSequence
            for await event in sequence {
                guard let self else { return }
                switch event {
                case let .request(request, handler, _):
                    await self.handleServerRequest(request, handler: handler)
                case let .notification(notification, data):
                    self.handleServerNotification(notification, data: data)
                case let .error(error):
                    self.logger.warning("JSON-RPC error: \(error)")
                }
            }
        }
    }

    private func handleServerRequest(
        _ request: AnyJSONRPCRequest,
        handler: JSONRPCEvent.RequestHandler
    ) async {
        switch request.method {
        case CopilotMethod.configuration:
            // Reply with one empty configuration object per requested item.
            let count = configurationItemCount(request.params)
            let reply = Array(repeating: CopilotEmptyObject(), count: max(count, 1))
            await handler(.success(reply))
        case CopilotMethod.workDoneProgressCreate:
            await handler(.success(CopilotEmptyObject()))
        case CopilotMethod.showDocument:
            await handler(.success(ShowDocumentResult(success: true)))
        default:
            // Reply with an empty object so unmodeled requests never block the server.
            await handler(.success(CopilotEmptyObject()))
        }
    }

    private func configurationItemCount(_ params: JSONValue?) -> Int {
        guard let params, case let .hash(hash) = params,
              let itemsValue = hash["items"], case let .array(items) = itemsValue else {
            return 1
        }
        return items.count
    }

    private func handleServerNotification(_ notification: AnyJSONRPCNotification, data: Data) {
        guard notification.method == CopilotMethod.didChangeStatusV2 else { return }
        guard let params: CopilotDidChangeStatusParams = decodeParams(notification.params) else { return }
        onStatusChange?(params)
    }

    private func decodeParams<T: Decodable>(_ params: JSONValue?) -> T? {
        guard let params else { return nil }
        do {
            let data = try JSONEncoder().encode(params)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger.warning("Failed to decode notification params: \(error)")
            return nil
        }
    }

    // MARK: - Lifecycle Requests

    @discardableResult
    func initialize(_ params: CopilotInitializeParams) async throws -> CopilotInitializeResult {
        try await session.response(to: CopilotMethod.initialize, params: params)
    }

    func sendInitialized() async throws {
        try await session.sendNotification(CopilotEmptyObject(), method: CopilotMethod.initialized)
        try await session.sendNotification(
            DidChangeConfigurationParams(settings: CopilotEmptyObject()),
            method: CopilotMethod.didChangeConfiguration
        )
    }

    // MARK: - Authentication Requests

    func checkStatus(localChecksOnly: Bool) async throws -> CopilotStatusResult {
        try await session.response(
            to: CopilotMethod.checkStatus,
            params: CopilotCheckStatusParams(options: .init(localChecksOnly: localChecksOnly))
        )
    }

    func signIn() async throws -> CopilotSignInResult {
        try await session.response(to: CopilotMethod.signIn, params: CopilotEmptyObject())
    }

    func signInWithGithubToken(_ token: String, user: String?) async throws -> CopilotStatusResult {
        try await session.response(
            to: CopilotMethod.signInWithGithubToken,
            params: CopilotSignInWithTokenParams(githubToken: token, user: user)
        )
    }

    func signOut() async throws -> CopilotStatusResult {
        try await session.response(to: CopilotMethod.signOut, params: CopilotEmptyObject())
    }

    @discardableResult
    func executeCommand(_ command: CopilotCommand) async throws -> JSONValue {
        try await session.response(
            to: CopilotMethod.executeCommand,
            params: CopilotExecuteCommandParams(command: command.command, arguments: command.arguments)
        )
    }

    // MARK: - Document Synchronization Notifications

    func didOpen(uri: String, languageId: String, version: Int, text: String) async throws {
        let params = CopilotDidOpenParams(
            textDocument: .init(uri: uri, languageId: languageId, version: version, text: text)
        )
        try await session.sendNotification(params, method: CopilotMethod.didOpen)
    }

    func didChange(uri: String, version: Int, text: String) async throws {
        let params = CopilotDidChangeParams(
            textDocument: .init(uri: uri, version: version),
            contentChanges: [.init(text: text)]
        )
        try await session.sendNotification(params, method: CopilotMethod.didChange)
    }

    func didClose(uri: String) async throws {
        try await session.sendNotification(
            CopilotDidCloseParams(textDocument: .init(uri: uri)),
            method: CopilotMethod.didClose
        )
    }

    func didFocus(uri: String) async throws {
        try await session.sendNotification(
            CopilotDidFocusParams(textDocument: .init(uri: uri)),
            method: CopilotMethod.didFocus
        )
    }

    // MARK: - Inline Completion

    func inlineCompletion(_ params: CopilotInlineCompletionParams) async throws -> CopilotInlineCompletionResult {
        try await session.response(to: CopilotMethod.inlineCompletion, params: params)
    }

    func didShowCompletion(item: CopilotCompletionItem) async throws {
        try await session.sendNotification(
            CopilotDidShowCompletionParams(item: item),
            method: CopilotMethod.didShowCompletion
        )
    }

    func didPartiallyAcceptCompletion(item: CopilotCompletionItem, acceptedLength: Int) async throws {
        try await session.sendNotification(
            CopilotDidPartiallyAcceptParams(item: item, acceptedLength: acceptedLength),
            method: CopilotMethod.didPartiallyAcceptCompletion
        )
    }
}
