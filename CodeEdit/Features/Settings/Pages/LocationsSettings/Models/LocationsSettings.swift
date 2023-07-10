//
//  LocationsSettings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 24/06/23.
//

import Foundation

extension SettingsData {

    struct LocationsSettings: SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Settings Location",
                "Themes Location",
                "Extensions Location"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }
    }
}
