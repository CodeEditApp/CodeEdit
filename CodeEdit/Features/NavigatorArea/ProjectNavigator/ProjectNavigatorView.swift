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
    var body: some View {
        ProjectNavigatorOutlineView()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ProjectNavigatorToolbarBottom()
            }
    }
}
