//
//  CopilotSettings.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation

extension SettingsData {
    /// Settings for the GitHub Copilot inline completion integration.
    struct CopilotSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "GitHub Copilot",
                "Copilot",
                "Inline Completion",
                "Code Completion",
                "AI",
                "Language Server"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Whether Copilot inline completions are enabled.
        var enabled: Bool = false

        /// An optional explicit path to the `copilot-language-server` binary. When empty, the binary is
        /// discovered automatically from `PATH` and common install locations.
        var languageServerPath: String = ""

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
            self.languageServerPath = try container.decodeIfPresent(
                String.self,
                forKey: .languageServerPath
            ) ?? ""
        }
    }
}
