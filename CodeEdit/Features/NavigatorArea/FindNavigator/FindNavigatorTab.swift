//
//  FindNavigatorTab.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import CodeEditSettings
import Search

/// App-side wrapper for the Search package's find navigator: reads Settings
/// (which the package cannot import) and passes them down as configuration.
struct FindNavigatorTab: View {
    @AppSettings(\.general.projectNavigatorSize)
    var projectNavigatorSize

    @AppSettings(\.general.findNavigatorDetail)
    var findNavigatorDetail

    var body: some View {
        FindNavigatorView(
            configuration: FindNavigatorConfiguration(
                rowHeight: projectNavigatorSize.rowHeight,
                matchDetailLineLimit: findNavigatorDetail.rawValue
            )
        )
    }
}
