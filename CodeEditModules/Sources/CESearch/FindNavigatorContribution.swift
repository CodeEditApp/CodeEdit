//
//  FindNavigatorContribution.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditSettings
import CodeEditUI
import SwiftUI

/// CESearch's navigator tab.
///
/// The package vends this itself; there is no app-side wrapper. Settings are read here through the
/// seam rather than passed down from the app, which is what the wrapper this replaced existed to do
/// before feature packages could read settings.
public struct FindNavigatorContribution: WorkspacePanelContribution {
    /// The single source of truth for this tab's id. The app-side `PanelTabID.search` references
    /// this constant so there is exactly one place the id is defined, even though ownership of the
    /// id now sits with the feature that owns the tab.
    public static let tabID = "search"

    public let id = FindNavigatorContribution.tabID
    public let title = "Search"
    public let systemImage = "magnifyingglass"

    public init() {}

    public var content: AnyView { AnyView(FindNavigatorContentView()) }

    public var bottomView: AnyView? { AnyView(FindNavigatorToolbarBottom()) }
}

/// Reads the settings the find navigator needs, so the contribution itself stays a plain value.
private struct FindNavigatorContentView: View {
    @SettingsValue(GeneralSettings.self, \.projectNavigatorSize)
    private var projectNavigatorSize

    @SettingsValue(GeneralSettings.self, \.findNavigatorDetail)
    private var findNavigatorDetail

    var body: some View {
        FindNavigatorView(
            configuration: FindNavigatorConfiguration(
                rowHeight: projectNavigatorSize.rowHeight,
                matchDetailLineLimit: findNavigatorDetail.rawValue
            )
        )
    }
}
