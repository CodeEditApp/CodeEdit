//
//  BufferingServerConnection.swift
//  CodeEditTests
//
//  Created by Khan Winter on 9/10/24.
//

import Foundation
import LanguageClient
import LanguageServerProtocol
import JSONRPC

/// Mock server connection that retains all requests and notifications in an array for comparing later.
///
/// To listen for changes, this type produces an async stream of all requests and notifications. Use the
/// `clientEventSequence` sequence to receive a copy of both whenever they're updated.
/// 
class BufferingServerConnection: ServerConnection {
    typealias ClientEventSequence = AsyncStream<([ClientRequest], [ClientNotification])>

    public var eventSequence: EventSequence

    /// A sequence of all events.
    public var clientEventSequence: ClientEventSequence
    private var clientEventContinuation: ClientEventSequence.Continuation

    private var id = 0

    public var clientRequests: [ClientRequest] = []
    public var clientNotifications: [ClientNotification] = []

    init() {
        let (sequence, _) = EventSequence.makeStream()
        self.eventSequence = sequence
        (clientEventSequence, clientEventContinuation) = ClientEventSequence.makeStream()
    }

    func sendNotification(_ notif: ClientNotification) async throws {
        clientNotifications.append(notif)
        clientEventContinuation.yield((clientRequests, clientNotifications))
    }

    func sendRequest<Response: Decodable & Sendable>(_ request: ClientRequest) async throws -> Response {
        defer {
            clientEventContinuation.yield((clientRequests, clientNotifications))
        }

        clientRequests.append(request)
        id += 1
        let response: Codable
        switch request {
        case .initialize:
            var capabilities = ServerCapabilities()
            capabilities.textDocumentSync = .optionA(.init(
                openClose: true, change: .incremental, willSave: true, willSaveWaitUntil: false, save: .optionA(true)
            ))
            response = InitializationResponse(capabilities: .init(), serverInfo: nil)
        default:
            response = JSONRPCResponse(id: .numericId(0), result: JSONRPCErrors.internalError)
        }
        let data = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
