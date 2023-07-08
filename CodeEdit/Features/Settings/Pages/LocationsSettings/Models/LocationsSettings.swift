//
//  LocationsSettings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 24/06/23.
//

import Foundation

extension SettingsData {

    enum LocationsSettings: SearchableSettingsPage {
        static var searchKeys: [String] {
            [
                "Settings Location",
                "Themes Location",
                "Extensions Location"
            ]
        }

        /// The URL of the `settings.json` file
        case settingsURL

        /// The URL of the `themes` folder
        case themesURL

        /// The URL of the `Extensions` folder
        case extensionsURL
    }
}
