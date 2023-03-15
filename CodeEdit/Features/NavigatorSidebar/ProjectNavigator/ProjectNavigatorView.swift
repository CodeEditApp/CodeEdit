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
/// And files.
///
/// When selecting a file it will open in the editor.
///
struct ProjectNavigatorView: View {

    @EnvironmentObject var tabManager: TabManager

    var body: some View {
        OutlineView(selection: $tabManager.activeTabGroup.selected)
    }
}
