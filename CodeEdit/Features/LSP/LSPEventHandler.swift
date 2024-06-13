//
//  LSPEventHandler.swift
//  CodeEdit
//
//  Created by Abe Malla on 6/1/24.
//

import LanguageClient
import LanguageServerProtocol

extension LSPService {

    internal func startListeningToEvents(for languageId: LanguageIdentifier) {
        guard let languageClient = languageClients[languageId] else {
            logger.error("Language client not found for \(languageId.rawValue)")
            return
        }

        // Create a new Task to listen to the events
        let task = Task {
            for await event in languageClient.lspInstance.eventSequence {
                handleEvent(event, for: languageId)
            }
        }
        eventListeningTasks[languageId] = task
    }

    internal func stopListeningToEvents(for languageId: LanguageIdentifier) {
        if let task = eventListeningTasks[languageId] {
            task.cancel()
            eventListeningTasks.removeValue(forKey: languageId)
        }
    }

    private func handleEvent(_ event: ServerEvent, for languageId: LanguageIdentifier) {
        switch event {
        case let .request(id, request):
            print("Request ID: \(id) for \(languageId.rawValue)")
            handleRequest(request)
        case let .notification(notification):
            handleNotification(notification)
        case let .error(error):
            print("Error from EventStream for \(languageId.rawValue): \(error)")
        }
    }

    private func handleRequest(_ request: ServerRequest) {
        switch request {
        case let .workspaceConfiguration(params, handler):
            print("workspaceConfiguration: \(params)")
        case let .workspaceFolders(handler):
            print("workspaceFolders: \(String(describing: handler))")
        case let .workspaceApplyEdit(params, handler):
            print("workspaceApplyEdit: \(params)")
        case let .clientRegisterCapability(params, handler):
            print("clientRegisterCapability: \(params)")
        case let .clientUnregisterCapability(params, handler):
            print("clientUnregisterCapability: \(params)")
        case let .workspaceCodeLensRefresh(handler):
            print("workspaceCodeLensRefresh: \(String(describing: handler))")
        case let .workspaceSemanticTokenRefresh(handler):
            print("workspaceSemanticTokenRefresh: \(String(describing: handler))")
        case let .windowShowMessageRequest(params, handler):
            print("windowShowMessageRequest: \(params)")
        case let .windowShowDocument(params, handler):
            print("windowShowDocument: \(params)")
        case let .windowWorkDoneProgressCreate(params, handler):
            print("windowWorkDoneProgressCreate: \(params)")

        // TODO:
        default:
            print()
        }
    }

    private func handleNotification(_ notification: ServerNotification) {
        switch notification {
        case let .windowLogMessage(params):
            print("windowLogMessage \(params.type)\n```\n\(params.message)\n```\n")
        case let .windowShowMessage(params):
            print("windowShowMessage \(params.type)\n```\n\(params.message)\n```\n")
        case let .textDocumentPublishDiagnostics(params):
            print("textDocumentPublishDiagnostics: \(params)")
        case let .telemetryEvent(params):
            print("telemetryEvent: \(params)")
        case let .protocolCancelRequest(params):
            print("protocolCancelRequest: \(params)")
        case let .protocolProgress(params):
            print("protocolProgress: \(params)")
        case let .protocolLogTrace(params):
            print("protocolLogTrace: \(params)")
        }
    }
}
