//
//  GitHistoryInspectorContribution.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 14/08/26.
//

import CodeEditCore
import CodeEditUI
import SwiftUI

/// CESourceControl's inspector tab.
///
/// Takes the workspace's active-file read-model as an initialiser parameter: the history it shows
/// follows the editor selection, and `\.activeEditorState` is an app-shell environment key.
public struct GitHistoryInspectorContribution: WorkspacePanelContribution {
    /// The single source of truth for this tab's id. The app-side `PanelTabID.gitHistory`
    /// references this constant so the id is defined in exactly one place.
    public static let tabID = "gitHistory"

    public let id = GitHistoryInspectorContribution.tabID
    public let title = "History Inspector"
    public let systemImage = "clock"

    private let activeEditorState: ActiveEditorState

    public init(activeEditorState: ActiveEditorState) {
        self.activeEditorState = activeEditorState
    }

    public var content: AnyView { AnyView(HistoryInspectorView(activeEditorState: activeEditorState)) }
}
