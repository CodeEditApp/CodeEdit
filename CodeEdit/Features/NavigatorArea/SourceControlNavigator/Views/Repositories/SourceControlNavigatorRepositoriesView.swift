//
//  SourceControlNavigatorRepositoriesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorRepositoriesView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SourceControlNavigatorBranchGroupView(
                    sourceControlManager: sourceControlManager,
                    branches: sourceControlManager.branches.filter({ $0.isLocal }),
                    name: "Branches",
                    isExpanded: true
                )

                SourceControlNavigatorBranchGroupView(
                    sourceControlManager: sourceControlManager,
                    branches: sourceControlManager.branches.filter({ $0.isRemote }),
                    name: "Remotes",
                    icon: "globe"
                )
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
        .task {
            await sourceControlManager.refreshBranches()
        }
    }
}
