//
//  ProjectNavigatorView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.22.
//

import SwiftUI

/// # Project Navigator - Sidebar
///
/// A list that functions as a project navigator, showing collapsible folders
/// and files.
///
/// When selecting a file it will open in the editor.
///
struct ProjectNavigatorView: View {
    @EnvironmentObject var workspace: WorkspaceDocument

    var root: (any Resource)? {
        workspace.fileTree
    }

    var body: some View {

//        List {
//            if let root {
//                OutlineGroup(root, id: \.id, children: \.children2) {
//                    Text($0.name)
//                }
//            }
////            ForEach(root.children, id: \.id) {
////                Text($0.name)
////            }
//        }
        ProjectNavigatorOutlineView()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ProjectNavigatorToolbarBottom()
            }
    }
}
