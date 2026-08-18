//
//  RemoteBranchPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/1/24.
//

import SwiftUI

struct RemoteBranchPicker: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @Binding var branch: GitBranch?
    @Binding var remote: GitRemote?

    let onSubmit: () -> Void
    let canCreateBranch: Bool

    var shouldCreateBranch: Bool {
        canCreateBranch && !(remote?.branches.contains(
            where: { $0.name == (sourceControlManager.currentBranch?.name ?? "") }
        ) ?? true)
    }

    var body: some View {
        Group {
            Picker(selection: $remote) {
                ForEach(sourceControlManager.remotes, id: \.name) { remote in
                    Label {
                        Text(remote.name)
                    } icon: {
                        Image(symbol: "vault")
                    }
                    .tag(remote as GitRemote?)
                }
                Divider()
                Text("Add Existing Remote...")
                    .tag(GitRemote?(nil))
            } label: {
                Text("Remote")
            }
            Picker(selection: $branch) {
                if shouldCreateBranch {
                    Label {
                        Text("\(sourceControlManager.currentBranch?.name ?? "") (Create)")
                    } icon: {
                        Image(symbol: "branch")
                    }
                    .tag(sourceControlManager.currentBranch)
                }
                if let branches = remote?.branches, !branches.isEmpty {
                    ForEach(branches, id: \.longName) { branch in
                        Label {
                            Text(branch.name)
                        } icon: {
                            Image(symbol: "branch")
                        }
                        .tag(branch as GitBranch?)
                    }
                }
            } label: {
                Text("Branch")
            }
        }
        .onAppear {
            if remote == nil {
                updateRemote()
            }
        }
        .onChange(of: remote) { _, newValue in
            if newValue == nil {
                sourceControlManager.addExistingRemoteSheetIsPresented = true
            } else {
                updateBranch()
            }
        }
    }

    private func updateRemote() {
        if let currentBranch = sourceControlManager.currentBranch, let upstream = currentBranch.upstream {
            self.remote = sourceControlManager.remotes.first(where: { upstream.starts(with: $0.name) })
        } else {
            self.remote = sourceControlManager.remotes.first
        }
    }

    private func updateBranch() {
        if shouldCreateBranch {
            self.branch = sourceControlManager.currentBranch
        } else if let currentBranch = sourceControlManager.currentBranch,
            let upstream = currentBranch.upstream,
            let remote = self.remote,
            let branchIndex = remote.branches.firstIndex(where: { upstream.contains($0.name) }) {
            self.branch = remote.branches[branchIndex]
        } else {
            self.branch = remote?.branches.first
        }
    }
}
