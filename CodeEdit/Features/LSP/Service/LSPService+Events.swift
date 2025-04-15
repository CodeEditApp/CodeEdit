//
//  LSPService+Events.swift
//  CodeEdit
//
//  Created by Abe Malla on 6/1/24.
//

import LanguageClient
import LanguageServerProtocol

extension LSPService {
    func startListeningToEvents(for key: ClientKey) {
        guard let languageClient = languageClients[key] else {
            logger.error("Language client not found for \(key.languageId.rawValue)")
            return
        }

        // Create a new Task to listen to the events
        let task = Task.detached { [weak self] in
            for await event in languageClient.lspInstance.eventSequence {
                await self?.handleEvent(event, for: languageClient)
            }
        }
        eventListeningTasks[key] = task
    }

    func stopListeningToEvents(for key: ClientKey) {
        if let task = eventListeningTasks[key] {
            task.cancel()
            eventListeningTasks.removeValue(forKey: key)
        }
    }

    private func handleEvent(
        _ event: ServerEvent,
        for languageClient: LanguageServer
    ) {
        // TODO: Handle Events
        switch event {
//        case let .request(id, request):
//            print("Request ID: \(id) for \(languageClient.languageId.rawValue)")
//            handleRequest(request, languageClient)
        case let .notification(notification):
            handleNotification(notification, languageClient)
//        case let .error(error):
//            print("Error from EventStream for \(languageClient.languageId.rawValue): \(error)")
        default:
            return
        }
    }

    private func handleRequest(
        _ request: ServerRequest,
        _ languageClient: LanguageServer
    ) {
        // TODO: Handle Requests
//        switch request {
//        case let .workspaceConfiguration(params, _):
//            print("workspaceConfiguration: \(params)")
//        case let .workspaceFolders(handler):
//            print("workspaceFolders: \(String(describing: handler))")
//        case let .workspaceApplyEdit(params, _):
//            print("workspaceApplyEdit: \(params)")
//        case let .clientRegisterCapability(params, _):
//            print("clientRegisterCapability: \(params)")
//        case let .clientUnregisterCapability(params, _):
//            print("clientUnregisterCapability: \(params)")
//        case let .workspaceCodeLensRefresh(handler):
//            print("workspaceCodeLensRefresh: \(String(describing: handler))")
//        case let .workspaceSemanticTokenRefresh(handler):
//            print("workspaceSemanticTokenRefresh: \(String(describing: handler))")
//        case let .windowShowMessageRequest(params, _):
//            print("windowShowMessageRequest: \(params)")
//        case let .windowShowDocument(params, _):
//            print("windowShowDocument: \(params)")
//        case let .windowWorkDoneProgressCreate(params, _):
//            print("windowWorkDoneProgressCreate: \(params)")
//
//        default:
//            print()
//        }
    }

    private func handleNotification(
        _ notification: ServerNotification,
        _ languageClient: LanguageServer
    ) {
        // TODO: Handle Notifications
        switch notification {
//        case let .windowLogMessage(params):
//            print("windowLogMessage \(params.type)\n```\n\(params.message)\n```\n")
//        case let .windowShowMessage(params):
//            print("windowShowMessage \(params.type)\n```\n\(params.message)\n```\n")
        case let .textDocumentPublishDiagnostics(params):
            print("textDocumentPublishDiagnostics: \(params.diagnostics)")
            languageClient.workspace.issueNavigatorViewModel?
                .updateDiagnostics(params: params)
//        case let .telemetryEvent(params):
//            print("telemetryEvent: \(params)")
//        case let .protocolCancelRequest(params):
//            print("protocolCancelRequest: \(params)")
//        case let .protocolProgress(params):
//            print("protocolProgress: \(params)")
//        case let .protocolLogTrace(params):
//            print("protocolLogTrace: \(params)")
        default:
            return
        }
    }
}
