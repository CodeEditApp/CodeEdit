//
//  AppLanguageServicesProvider.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 2026/07/09.
//

import CodeEditDocument
import Factory

@MainActor
final class AppLanguageServicesProvider: LanguageServicesProvider {
    @LazyInjected(\.lspService) private var lspService

    func languageServices(for document: CodeFileDocument) -> LanguageServices {
        let objects = lspService.languageServerObjects(for: document)
        return LanguageServices(
            textCoordinator: objects.textCoordinator,
            highlightProvider: objects.highlightProvider
        )
    }
}
