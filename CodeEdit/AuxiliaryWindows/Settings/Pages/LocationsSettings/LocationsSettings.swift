//
//  LocationsSettings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 24/06/23.
//

import Foundation
import CodeEditSettings

/// The Locations settings page.
///
/// Not a `SettingsSection`: it persists nothing, it only lists where things already live. It used to
/// be nested inside `SettingsData`, which read as if it were one of the stored sections.
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
