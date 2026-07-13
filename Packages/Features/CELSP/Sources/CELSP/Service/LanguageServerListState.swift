//
//  LanguageServerListState.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Foundation
import LanguageServerProtocol

/// A running language server, as presented to UI (the output-source picker).
public struct RunningLanguageServer: Identifiable {
    public let workspacePath: String
    public let languageId: LanguageIdentifier
    public let logContainer: LanguageServerLogContainer
    public var id: String { workspacePath + languageId.rawValue }
}

/// Observable list of running language servers. Owned and fed by
/// ``LSPService``; observed by the utility-area output-source picker.
@MainActor
public final class LanguageServerListState: ObservableObject {
    @Published public private(set) var runningServers: [RunningLanguageServer] = []

    func add(_ server: RunningLanguageServer) {
        runningServers.removeAll { $0.id == server.id }
        runningServers.append(server)
    }

    func remove(workspacePath: String, languageId: LanguageIdentifier) {
        runningServers.removeAll { $0.workspacePath == workspacePath && $0.languageId == languageId }
    }

    func removeAll(workspacePath: String) {
        runningServers.removeAll { $0.workspacePath == workspacePath }
    }

    func removeAll() {
        runningServers.removeAll()
    }
}
