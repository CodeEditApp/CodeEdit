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
        let (sequence, continuation) = EventSequence.makeStream()
        self.eventSequence = sequence
    }

    func sendNotification(_ notif: ClientNotification) async throws {
        clientNotifications.append(notif)
    }

    func sendRequest<Response: Decodable & Sendable>(_ request: ClientRequest) async throws -> Response {
        clientRequests.append(request)
        id += 1
        switch request {
        case .initialize:
            var capabilities = ServerCapabilities()
            capabilities.textDocumentSync = .optionA(.init(
                openClose: true, change: .incremental, willSave: true, willSaveWaitUntil: false, save: .optionA(true)
            ))
            return InitializationResponse(capabilities: .init(), serverInfo: nil) as! Response
        default:
            return JSONRPCResponse(id: .numericId(id), result: "buh") as! Response
        }
    }
}
