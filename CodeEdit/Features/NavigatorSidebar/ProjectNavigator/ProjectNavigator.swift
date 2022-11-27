//
//  NavigatorSidebar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.22.
//

import SwiftUI

/// # Project Navigator - Sidebar
///
/// A list that functions as a project navigator, showing collapsable folders
/// and files.
///
/// When selecting a file it will open in the editor.
///
struct ProjectNavigator: View {
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController

    var body: some View {
        OutlineView(workspace: workspace)
    }
}
