//
//  FeatureFlagsSettings.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 17/06/2023.
//

import Foundation

extension SettingsData {

    struct FeatureFlagsSettings: Codable, Hashable {
        var useNewWindowingSystem = false
    }
}
