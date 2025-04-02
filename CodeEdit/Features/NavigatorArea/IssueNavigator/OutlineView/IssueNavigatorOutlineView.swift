//
//  IssueNavigatorOutlineView.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import SwiftUI
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct IssueNavigatorOutlineView: NSViewControllerRepresentable {

    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var editorManager: EditorManager

    @StateObject var prefs: Settings = .shared

    typealias NSViewControllerType = IssueNavigatorViewController

    func makeNSViewController(context: Context) -> IssueNavigatorViewController {
        let controller = IssueNavigatorViewController()
        controller.workspace = workspace
        controller.editor = editorManager.activeEditor
        return controller
    }

    func updateNSViewController(_ nsViewController: IssueNavigatorViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
    }
}
