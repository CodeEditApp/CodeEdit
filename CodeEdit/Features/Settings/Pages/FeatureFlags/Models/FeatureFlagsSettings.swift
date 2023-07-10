//
//  FeatureFlagsSettings.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 17/06/2023.
//

import Foundation

extension SettingsData {

    struct FeatureFlagsSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "New Windowing System"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        var useNewWindowingSystem = false
    }
}
