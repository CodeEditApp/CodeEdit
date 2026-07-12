//
//  AppLanguageServicesProvider.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 2026/07/09.
//

import CodeEditDocument

@MainActor
public final class AppLanguageServicesProvider: LanguageServicesProvider {
    private let lspService: LSPService

    public init(lspService: LSPService) {
        self.lspService = lspService
    }

    public func languageServices(for document: CodeFileDocument) -> LanguageServices {
        let objects = lspService.languageServerObjects(for: document)
        return LanguageServices(
            textCoordinator: objects.textCoordinator,
            highlightProvider: objects.highlightProvider
        )
    }
}
