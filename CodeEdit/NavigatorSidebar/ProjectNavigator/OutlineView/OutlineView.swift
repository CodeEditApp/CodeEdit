//
//  OutlineView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 05.04.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct OutlineView: NSViewControllerRepresentable {

    @StateObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = OutlineViewController

    func makeNSViewController(context: Context) -> OutlineViewController {
        let controller = OutlineViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle

        return controller
    }

    func updateNSViewController(_ nsViewController: OutlineViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        nsViewController.updateSelection()
        return
    }

    /// Returns the row height depending on the `projectNavigatorSize` in `AppPreferences`.
    ///
    /// * `small`: 20
    /// * `medium`: 22
    /// * `large`: 24
    private var rowHeight: Double {
        switch prefs.preferences.general.projectNavigatorSize {
        case .small: return 20
        case .medium: return 22
        case .large: return 24
        }
    }
}
