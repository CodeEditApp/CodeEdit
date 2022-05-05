//
//  SourceControlNavigatorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//

import SwiftUI
import CodeEditUI

struct SourceControlNavigatorView: View {

    @ObservedObject
    private var workspace: WorkspaceDocument

    @State
    private var selectedSection: Int = 0

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            SourceControlToolbar {
                SegmentedControl($selectedSection, options: ["Changes", "Repositories"])
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
            .overlay(alignment: .bottom) {
                Divider()
            }

            if selectedSection == 0 {
                ChangesView(workspaceURL: workspace.fileURL!)
            }
            if selectedSection == 1 {
                RepositoriesView()
            }
        }
    }
}
