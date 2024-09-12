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

class BufferingServerConnection: ServerConnection {
    var eventSequence: EventSequence
    private var id = 0

    public var clientRequests: [ClientRequest] = []
    public var clientNotifications: [ClientNotification] = []

    init() {
        let (sequence, _) = EventSequence.makeStream()
        self.eventSequence = sequence
    }

    func sendNotification(_ notif: ClientNotification) async throws {
        clientNotifications.append(notif)
    }

    func sendRequest<Response: Decodable & Sendable>(_ request: ClientRequest) async throws -> Response {
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
