//
//  LanguageServerLogContainer+UtilityArea.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import Foundation
import CELSP

/// Adapts CELSP's log container to the UtilityArea output protocols. Lives app-side so
/// the package stays free of UtilityArea types.
extension LanguageServerLogContainer: UtilityAreaOutputSource {}

extension LanguageServerLogContainer.LanguageServerMessage: UtilityAreaOutputMessage {
    var level: UtilityAreaLogLevel {
        switch log.type {
        case .error:
                .error
        case .warning:
                .warning
        case .info:
                .info
        case .log:
                .debug
        }
    }
}
