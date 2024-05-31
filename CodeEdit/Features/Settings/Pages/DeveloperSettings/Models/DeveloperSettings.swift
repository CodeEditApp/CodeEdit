//
//  DeveloperSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/15/24.
//

import Foundation

extension SettingsData {
    struct DeveloperSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Developer",
                "Language Server Protocol",
                "LSP Binaries"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// A dictionary that stores a file type and a path to an LSP binary
        var lspBinaries: [String: String] = [:]

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.lspBinaries = try container.decodeIfPresent(
                [String: String].self,
                forKey: .lspBinaries
            ) ?? [:]
        }
    }
}
