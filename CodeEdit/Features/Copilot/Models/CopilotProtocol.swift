//
//  CopilotProtocol.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation
import JSONRPC

/// An empty JSON object (`{}`) used for request params and replies that carry no data.
struct CopilotEmptyObject: Codable, Sendable {}

/// A `name`/`version` pair, used for `clientInfo`, `editorInfo`, and `editorPluginInfo`.
struct CopilotNameVersion: Codable, Sendable {
    let name: String
    let version: String
}

// MARK: - Initialize

/// Parameters for the `initialize` request.
///
/// The Copilot language server requires both `editorInfo` and `editorPluginInfo` inside
/// `initializationOptions`, and advertises `textDocument.inlineCompletion` support.
struct CopilotInitializeParams: Codable, Sendable {
    struct Capabilities: Codable, Sendable {
        struct Workspace: Codable, Sendable {
            let workspaceFolders: Bool
            let configuration: Bool
        }
        struct TextDocument: Codable, Sendable {
            let inlineCompletion: CopilotEmptyObject
        }
        let workspace: Workspace
        let textDocument: TextDocument
    }

    struct InitializationOptions: Codable, Sendable {
        let editorInfo: CopilotNameVersion
        let editorPluginInfo: CopilotNameVersion
    }

    struct WorkspaceFolder: Codable, Sendable {
        let uri: String
        let name: String
    }

    let processId: Int?
    let clientInfo: CopilotNameVersion
    let rootUri: String?
    let workspaceFolders: [WorkspaceFolder]?
    let capabilities: Capabilities
    let initializationOptions: InitializationOptions
}

/// The subset of the `initialize` response capabilities CodeEdit inspects.
struct CopilotInitializeResult: Codable, Sendable {
    struct Capabilities: Codable, Sendable {
        struct ExecuteCommandProvider: Codable, Sendable {
            let commands: [String]?
        }
        /// Present (as an empty object) when the server supports inline completions.
        let inlineCompletionProvider: JSONValue?
        let executeCommandProvider: ExecuteCommandProvider?
    }
    let capabilities: Capabilities
}

// MARK: - Authentication

/// Parameters for the `checkStatus` request.
struct CopilotCheckStatusParams: Codable, Sendable {
    struct Options: Codable, Sendable {
        let localChecksOnly: Bool
    }
    let options: Options
}

/// Result of `checkStatus`, `signOut`, and `signInWithGithubToken`.
struct CopilotStatusResult: Codable, Sendable {
    let status: String
    let user: String?
}

/// Result of the `signIn` request describing the GitHub device flow.
struct CopilotSignInResult: Codable, Sendable {
    let status: String
    let userCode: String?
    let verificationUri: String?
    let expiresIn: Int?
    let interval: Int?
    let user: String?
    let command: CopilotCommand?
}

/// Parameters for `signInWithGithubToken`.
struct CopilotSignInWithTokenParams: Codable, Sendable {
    let githubToken: String
    let user: String?
}

// MARK: - Commands

/// An LSP `Command` as returned by the server (for device-flow completion and accept telemetry).
struct CopilotCommand: Codable, Sendable {
    let command: String
    let title: String?
    let arguments: [JSONValue]?
}

/// Parameters for `workspace/executeCommand`.
struct CopilotExecuteCommandParams: Codable, Sendable {
    let command: String
    let arguments: [JSONValue]?
}

// MARK: - Document Synchronization

struct CopilotTextDocumentItem: Codable, Sendable {
    let uri: String
    let languageId: String
    let version: Int
    let text: String
}

struct CopilotVersionedDocumentIdentifier: Codable, Sendable {
    let uri: String
    let version: Int
}

struct CopilotDocumentIdentifier: Codable, Sendable {
    let uri: String
}

struct CopilotContentChange: Codable, Sendable {
    let text: String
}

struct CopilotDidOpenParams: Codable, Sendable {
    let textDocument: CopilotTextDocumentItem
}

struct CopilotDidChangeParams: Codable, Sendable {
    let textDocument: CopilotVersionedDocumentIdentifier
    let contentChanges: [CopilotContentChange]
}

struct CopilotDidCloseParams: Codable, Sendable {
    let textDocument: CopilotDocumentIdentifier
}

struct CopilotDidFocusParams: Codable, Sendable {
    let textDocument: CopilotDocumentIdentifier
}

// MARK: - Inline Completion

struct CopilotPosition: Codable, Sendable {
    let line: Int
    let character: Int
}

struct CopilotRange: Codable, Sendable {
    let start: CopilotPosition
    let end: CopilotPosition
}

/// The trigger reason for an inline completion request. CodeEdit always requests automatically.
enum CopilotInlineTriggerKind: Int, Codable, Sendable {
    case invoked = 1
    case automatic = 2
}

struct CopilotInlineCompletionContext: Codable, Sendable {
    let triggerKind: Int
}

struct CopilotFormattingOptions: Codable, Sendable {
    let tabSize: Int
    let insertSpaces: Bool
}

struct CopilotInlineCompletionParams: Codable, Sendable {
    let textDocument: CopilotVersionedDocumentIdentifier
    let position: CopilotPosition
    let context: CopilotInlineCompletionContext
    let formattingOptions: CopilotFormattingOptions?
}

/// A single inline completion suggestion returned by the server.
struct CopilotCompletionItem: Codable, Sendable {
    let insertText: String
    let range: CopilotRange?
    let command: CopilotCommand?
}

struct CopilotInlineCompletionResult: Codable, Sendable {
    let items: [CopilotCompletionItem]
}

// MARK: - Telemetry

struct CopilotDidShowCompletionParams: Codable, Sendable {
    let item: CopilotCompletionItem
}

struct CopilotDidPartiallyAcceptParams: Codable, Sendable {
    let item: CopilotCompletionItem
    let acceptedLength: Int
}

// MARK: - Server Notifications

/// Payload of the `didChangeStatus/v2` notification.
struct CopilotDidChangeStatusParams: Codable, Sendable {
    struct Status: Codable, Sendable {
        struct Result: Codable, Sendable {
            let status: String?
        }
        let category: String
        let kind: String?
        let message: String?
        let result: Result?
    }
    let statuses: [Status]
}

// MARK: - Method Names

/// String constants for the custom Copilot JSON-RPC methods not modeled by `LanguageServerProtocol`.
enum CopilotMethod {
    static let initialize = "initialize"
    static let initialized = "initialized"
    static let didChangeConfiguration = "workspace/didChangeConfiguration"
    static let checkStatus = "checkStatus"
    static let signIn = "signIn"
    static let signInWithGithubToken = "signInWithGithubToken"
    static let signOut = "signOut"
    static let executeCommand = "workspace/executeCommand"
    static let didOpen = "textDocument/didOpen"
    static let didChange = "textDocument/didChange"
    static let didClose = "textDocument/didClose"
    static let didFocus = "textDocument/didFocus"
    static let inlineCompletion = "textDocument/inlineCompletion"
    static let didShowCompletion = "textDocument/didShowCompletion"
    static let didPartiallyAcceptCompletion = "textDocument/didPartiallyAcceptCompletion"

    // Server to client
    static let configuration = "workspace/configuration"
    static let workDoneProgressCreate = "window/workDoneProgress/create"
    static let showDocument = "window/showDocument"
    static let didChangeStatusV2 = "didChangeStatus/v2"

    // Commands
    static let finishDeviceFlow = "github.copilot.finishDeviceFlow"
    static let didAcceptCompletionItem = "github.copilot.didAcceptCompletionItem"
}

/// The JSON-RPC error code the server returns when an inline completion is requested while signed out.
let copilotNotAuthenticatedErrorCode = 1000
