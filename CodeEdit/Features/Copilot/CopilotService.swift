//
//  CopilotService.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation
import JSONRPC
import OSLog
import SwiftUI

/// The authentication state of the GitHub Copilot language server, surfaced to the UI.
enum CopilotAuthState: Equatable {
    /// No user is signed in.
    case signedOut
    /// A device-flow sign-in is in progress; the user must enter `userCode` at `verificationUri`.
    case awaitingDeviceCode(userCode: String, verificationUri: String)
    /// A user is signed in.
    case signedIn(user: String)
    /// An error occurred. The associated value is a human-readable description.
    case error(String)
}

/// Manages the lifecycle of the GitHub Copilot language server and exposes its authentication state.
///
/// `CopilotService` owns the ``CopilotClient`` (and therefore the language-server process and JSON-RPC session),
/// drives the device-flow sign-in, tracks document synchronization versions, and brokers inline-completion
/// requests on behalf of ``CopilotInlineCompletionProvider``.
///
/// It is a singleton registered with ``ServiceContainer`` alongside ``LSPService`` and is observed by the UI
/// (settings page, status bar) as an `ObservableObject`.
@MainActor
final class CopilotService: ObservableObject {
    /// The shared instance. The same instance is registered with ``ServiceContainer``.
    static let shared = CopilotService()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CopilotService")

    /// The current authentication state.
    @Published private(set) var authState: CopilotAuthState = .signedOut
    /// Whether a request (sign-in, status check, completion) is currently in flight.
    @Published private(set) var isBusy: Bool = false
    /// Whether the language-server process is running and initialized.
    @Published private(set) var isRunning: Bool = false

    private var client: CopilotClient?
    private var isInitialized = false

    /// The `command` returned by the latest `signIn` response, used to finish the device flow.
    private var pendingDeviceFlowCommand: CopilotCommand?

    /// Tracks the synced version and last text for each open document URI.
    private var syncedDocuments: [String: (version: Int, text: String)] = [:]

    private init() {
        NotificationCenter.default.addObserver(
            forName: CodeFileDocument.didCloseNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                guard let url = notification.object as? URL else { return }
                Task { await self?.closeDocument(uri: url.lspURI) }
            }
        }
    }

    /// Whether the user has enabled Copilot in settings.
    var isEnabled: Bool {
        Settings.shared.preferences.copilot.enabled
    }

    /// Whether a user is currently signed in.
    var isSignedIn: Bool {
        if case .signedIn = authState { return true }
        return false
    }

    private var settings: SettingsData.CopilotSettings {
        Settings.shared.preferences.copilot
    }

    // MARK: - Lifecycle

    /// Starts and initializes the language server if it is not already running.
    ///
    /// Resolves the binary, launches the process, sends `initialize`/`initialized`, then performs a status check
    /// (priming with an environment token if one is available and the user is signed out).
    func initializeIfNeeded() async {
        guard !isInitialized else { return }
        isBusy = true
        defer { isBusy = false }

        guard let binaryPath = CopilotBinaryResolver.resolveBinaryPath(
            configuredPath: settings.languageServerPath
        ) else {
            authState = .error("Could not find the copilot-language-server binary. Set its path in settings.")
            return
        }

        do {
            let client = try CopilotClient.launch(
                binaryPath: binaryPath,
                environment: CopilotBinaryResolver.augmentedEnvironment(forBinaryAt: binaryPath),
                terminationHandler: { [weak self] in
                    Task { @MainActor in self?.handleTermination() }
                }
            )
            client.onStatusChange = { [weak self] params in
                Task { @MainActor in self?.handleStatusChange(params) }
            }
            self.client = client

            let result = try await client.initialize(makeInitializeParams())
            guard result.capabilities.inlineCompletionProvider != nil else {
                authState = .error("Server does not advertise inline completion support.")
                return
            }
            try await client.sendInitialized()
            isInitialized = true
            isRunning = true

            await refreshStatus(localChecksOnly: false)
            await primeWithEnvironmentTokenIfNeeded()
        } catch {
            logger.error("Failed to initialize Copilot: \(error)")
            authState = .error(error.localizedDescription)
            isRunning = false
        }
    }

    /// Terminates the language server and resets all state.
    func shutdown() {
        client?.process.terminate()
        client = nil
        isInitialized = false
        isRunning = false
        syncedDocuments.removeAll()
    }

    private func handleTermination() {
        logger.warning("Copilot language server terminated")
        client = nil
        isInitialized = false
        isRunning = false
        syncedDocuments.removeAll()
    }

    // MARK: - Authentication

    /// Re-checks the authentication status with the server.
    func checkStatus() async {
        await initializeIfNeeded()
        await refreshStatus(localChecksOnly: false)
    }

    private func refreshStatus(localChecksOnly: Bool) async {
        guard let client else { return }
        do {
            let status = try await client.checkStatus(localChecksOnly: localChecksOnly)
            applyStatus(status.status, user: status.user)
        } catch {
            logger.error("checkStatus failed: \(error)")
        }
    }

    /// Begins the GitHub device-flow sign-in, moving to the `awaitingDeviceCode` state with the user code.
    func signIn() async {
        await initializeIfNeeded()
        guard let client else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            let result = try await client.signIn()
            if result.status == "AlreadySignedIn" {
                applyStatus("OK", user: result.user)
                return
            }
            guard let userCode = result.userCode, let verificationUri = result.verificationUri else {
                authState = .error("Sign-in did not return a device code.")
                return
            }
            pendingDeviceFlowCommand = result.command
            authState = .awaitingDeviceCode(userCode: userCode, verificationUri: verificationUri)
        } catch {
            logger.error("signIn failed: \(error)")
            authState = .error(error.localizedDescription)
        }
    }

    /// Completes the device flow by executing the `finishDeviceFlow` command returned by ``signIn()``.
    ///
    /// This call blocks server-side until the user authorizes the code in their browser.
    func confirmDeviceFlow() async {
        guard let client, let command = pendingDeviceFlowCommand else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await client.executeCommand(command)
            pendingDeviceFlowCommand = nil
            await refreshStatus(localChecksOnly: false)
        } catch {
            logger.error("finishDeviceFlow failed: \(error)")
            authState = .error(error.localizedDescription)
        }
    }

    /// Signs the current user out of Copilot.
    func signOut() async {
        guard let client else {
            authState = .signedOut
            return
        }
        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await client.signOut()
            authState = .signedOut
        } catch {
            logger.error("signOut failed: \(error)")
            authState = .error(error.localizedDescription)
        }
    }

    private func primeWithEnvironmentTokenIfNeeded() async {
        guard case .signedOut = authState, let client else { return }
        let environment = ProcessInfo.processInfo.environment
        guard let token = environment["GH_COPILOT_TOKEN"] ?? environment["GITHUB_COPILOT_TOKEN"] else { return }
        do {
            let status = try await client.signInWithGithubToken(token, user: nil)
            applyStatus(status.status, user: status.user)
        } catch {
            logger.warning("Environment token sign-in failed: \(error)")
        }
    }

    private func applyStatus(_ status: String, user: String?) {
        switch status {
        case "OK", "MaybeOk", "AlreadySignedIn":
            authState = .signedIn(user: user ?? "GitHub user")
        case "NotSignedIn", "NotAuthorized":
            if case .awaitingDeviceCode = authState { return } // keep prompting during the flow
            authState = .signedOut
        default:
            authState = .signedOut
        }
    }

    private func handleStatusChange(_ params: CopilotDidChangeStatusParams) {
        for status in params.statuses where status.category == "auth" {
            if let resultStatus = status.result?.status {
                applyStatus(resultStatus, user: nil)
            }
        }
    }

    // MARK: - Document Synchronization

    /// Sends `didOpen` the first time a URI is seen, otherwise a full-text `didChange` with a bumped version.
    func syncDocument(uri: String, languageId: String, text: String) async {
        guard let client else { return }
        if let existing = syncedDocuments[uri] {
            guard existing.text != text else { return }
            let version = existing.version + 1
            syncedDocuments[uri] = (version, text)
            try? await client.didChange(uri: uri, version: version, text: text)
        } else {
            syncedDocuments[uri] = (1, text)
            try? await client.didOpen(uri: uri, languageId: languageId, version: 1, text: text)
        }
    }

    /// Notifies the server a document was closed and forgets its sync state.
    func closeDocument(uri: String) async {
        guard let client, syncedDocuments[uri] != nil else { return }
        syncedDocuments.removeValue(forKey: uri)
        try? await client.didClose(uri: uri)
    }

    // MARK: - Inline Completion

    /// Requests inline completions for a synced document.
    ///
    /// Returns an empty array (and transitions to ``CopilotAuthState/signedOut``) if the server reports the
    /// not-authenticated error (code 1000).
    func requestInlineCompletion(
        uri: String,
        position: CopilotPosition,
        tabWidth: Int
    ) async -> [CopilotCompletionItem] {
        guard let client else { return [] }
        let version = syncedDocuments[uri]?.version ?? 1
        let params = CopilotInlineCompletionParams(
            textDocument: .init(uri: uri, version: version),
            position: position,
            context: .init(triggerKind: CopilotInlineTriggerKind.automatic.rawValue),
            formattingOptions: .init(tabSize: tabWidth, insertSpaces: true)
        )
        do {
            return try await client.inlineCompletion(params).items
        } catch let error as JSONRPCResponseError<JSONValue> where error.code == copilotNotAuthenticatedErrorCode {
            authState = .signedOut
            return []
        } catch {
            logger.warning("inlineCompletion failed: \(error)")
            return []
        }
    }

    /// Reports that an item was shown (telemetry).
    func reportShown(item: CopilotCompletionItem) {
        guard let client else { return }
        Task { try? await client.didShowCompletion(item: item) }
    }

    /// Reports that an item was fully accepted by executing its `command` (telemetry).
    func reportAccepted(item: CopilotCompletionItem) {
        guard let client, let command = item.command else { return }
        Task { _ = try? await client.executeCommand(command) }
    }

    // MARK: - Initialize Params

    private func makeInitializeParams() -> CopilotInitializeParams {
        let version = Bundle.versionString ?? "1.0"
        let rootUri = FileManager.default.homeDirectoryForCurrentUser.lspURI
        return CopilotInitializeParams(
            processId: Int(ProcessInfo.processInfo.processIdentifier),
            clientInfo: .init(name: "CodeEdit", version: version),
            rootUri: rootUri,
            workspaceFolders: [.init(uri: rootUri, name: "CodeEdit")],
            capabilities: .init(
                workspace: .init(workspaceFolders: true, configuration: true),
                textDocument: .init(inlineCompletion: CopilotEmptyObject())
            ),
            initializationOptions: .init(
                editorInfo: .init(name: "CodeEdit", version: version),
                editorPluginInfo: .init(name: "CodeEdit-Copilot", version: version)
            )
        )
    }
}
