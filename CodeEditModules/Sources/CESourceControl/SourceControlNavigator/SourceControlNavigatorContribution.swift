//
//  SourceControlNavigatorContribution.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 14/08/26.
//

import CodeEditCore
import CodeEditUI
import SwiftUI

/// CESourceControl's navigator tab.
///
/// The package vends this itself; there is no app-side wrapper. The one dependency the tab cannot
/// resolve for itself — the command interface for opening a changed file — arrives as an
/// initialiser parameter from the composition root rather than through an environment key the
/// package does not own.
public struct SourceControlNavigatorContribution: WorkspacePanelContribution {
    /// The single source of truth for this tab's id. The app-side `PanelTabID.sourceControl`
    /// references this constant so the id is defined in exactly one place.
    public static let tabID = "sourceControl"

    public let id = SourceControlNavigatorContribution.tabID
    public let title = "Source Control"
    public let systemImage = "vault"

    private let navigator: WorkspaceNavigator

    public init(navigator: WorkspaceNavigator) {
        self.navigator = navigator
    }

    public var content: AnyView { AnyView(SourceControlNavigatorView(navigator: navigator)) }
}
