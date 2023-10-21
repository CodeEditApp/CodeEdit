//
//  SourceControlNavigatorBranchGroupView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/21/23.
//

import SwiftUI

struct SourceControlNavigatorBranchGroupView: View {
    let sourceControlManager: SourceControlManager
    let branches: [GitBranch]
    let name: String
    var icon: String = "opticaldiscdrive.fill"
    @State var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 0) {
                ForEach(branches, id: \.self) { branch in
                    SourceControlNavigatorBranchView(
                        sourceControlManager: sourceControlManager,
                        branch: branch
                    )
                }
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(name)
            }
        }
    }
}
