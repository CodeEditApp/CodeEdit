//
//  Environment+LanguageServices.swift
//  Editor
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI
import CodeEditDocument

private struct LanguageServicesKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: LanguageServicesProvider = NoOpLanguageServicesProvider()
}

extension EnvironmentValues {
    /// Vends per-document language services (text coordinator + highlight provider).
    /// No-op by default (previews render without LSP); injected by the app shell.
    public var languageServices: LanguageServicesProvider {
        get { self[LanguageServicesKey.self] }
        set { self[LanguageServicesKey.self] = newValue }
    }
}
