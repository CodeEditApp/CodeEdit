//
//  LSPServiceProtocol.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import Foundation
import CodeEditDocument

/// Protocol for managing Language Server Protocol services.
///
/// Note: `languageClients` is not included here because consumers that need
/// reactive observation of `@Published` properties require the concrete type.
/// Use `LSPService` directly in those cases.
@MainActor
public protocol LSPServiceProtocol: AnyObject {
    func openDocument(_ document: CodeFileDocument)
    func closeDocument(_ url: URL)
    func closeWorkspace(_ workspacePath: String)
    func stopAllServers() async
    func killAllServers()
}
