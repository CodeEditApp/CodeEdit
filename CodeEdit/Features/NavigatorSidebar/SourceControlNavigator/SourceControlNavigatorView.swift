//
//  SourceControlNavigatorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorView: View {

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State
    private var selectedSection: Int = 0

    var body: some View {
        VStack {
            SegmentedControl(
                $selectedSection,
                options: ["Changes", "Repositories"],
                prominent: true
            )
            .frame(maxWidth: .infinity)
            .frame(height: 27)
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
            .overlay(alignment: .bottom) {
                Divider()
            }

            if selectedSection == 0 {
                if let urlString = workspace.fileURL {
                    SourceControlNavigatorChangesView(workspaceURL: urlString)
                }
            }

            if selectedSection == 1 {
                SourceControlNavigatorRepositoriesView()
            }
        }
    }
}
