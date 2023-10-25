//
//  SourceControlNavigatorBranchView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/21/23.
//

import SwiftUI

struct SourceControlNavigatorBranchView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State var showNewBranch: Bool = false
    let branch: GitBranch

    var body: some View {
        HStack {
            Image(systemName: "arrow.branch")
                .foregroundStyle(.secondary)
            Text(branch.name)

            if sourceControlManager.currentBranch == branch {
                Text("(current)")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.leading, 20)
        .frame(height: 25)
        .sheet(isPresented: $showNewBranch, content: {
            SourceControlNavigatorNewBranchView(
                sourceControlManager: sourceControlManager,
                fromBranch: branch
            )
        })
        .contextMenu {
            Button("Checkout") {
                Task {
                    do {
                        try await sourceControlManager.checkoutBranch(branch: branch)
                    } catch {
                        await sourceControlManager.showAlertForError(title: "Failed to checkout", error: error)
                    }
                }
            }
            if branch.isLocal {
                Divider()
                Button("New Branch from \"\(branch.name)\"") {
                    showNewBranch = true
                }
            }
            if branch.isLocal && sourceControlManager.currentBranch != branch {
                Divider()
                Button("Delete") {
                    Task {
                        do {
                            try await sourceControlManager.deleteBranch(branch: branch)
                        } catch {
                            await sourceControlManager.showAlertForError(title: "Failed to delete", error: error)
                        }
                    }
                }
            }
        }
    }
}
