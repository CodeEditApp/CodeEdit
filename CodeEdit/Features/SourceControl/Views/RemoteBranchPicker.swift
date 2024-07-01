//
//  RemoteBranchPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/1/24.
//

import SwiftUI

struct RemoteBranchPicker: View {
    @EnvironmentObject var scm: SourceControlManager

    @Binding var branch: GitBranch?
    @Binding var remote: GitRemote? {
        didSet {
            updateBranch()
        }
    }

    let onSubmit: () -> Void
    let canCreateBranch: Bool

    var shouldCreateBranch: Bool {
        canCreateBranch && !(remote?.branches?.contains(where: { $0.name == (scm.currentBranch?.name ?? "") }) ?? true)
    }

    var body: some View {
        Group {
            Picker(selection: $remote) {
                ForEach(scm.remotes, id: \.name) { remote in
                    Label {
                        Text(remote.name)
                    } icon: {
                        Image(symbol: "vault")
                    }
                    .tag(remote as GitRemote?)
                }
                Divider()
                Button("Add Existing Remote...") {
                     scm.remoteSheetIsPresented = true
                }
            } label: {
                Text("Remote")
            }
            Picker(selection: $branch) {
                if let branches = remote?.branches, !branches.isEmpty {
                    if shouldCreateBranch {
                        Label {
                            Text("\(scm.currentBranch?.name ?? "") (Create)")
                        } icon: {
                            Image(symbol: "branch")
                        }
                        .tag(scm.currentBranch)
                    }
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
            updateRemote()
        }
    }

    private func updateRemote() {
        if let currentBranch = scm.currentBranch, let upstream = currentBranch.upstream {
            self.remote = scm.remotes.first(where: { upstream.starts(with: $0.name) })
        } else {
            self.remote = scm.remotes.first
        }
    }

    private func updateBranch() {
        if shouldCreateBranch {
            self.branch = scm.currentBranch
        } else if let currentBranch = scm.currentBranch,
             let upstream = currentBranch.upstream,
             let remote = self.remote,
             let branches = remote.branches,
             let branchIndex = branches.firstIndex(where: { upstream.contains($0.name) }) {
              self.branch = branches[branchIndex]
          } else {
            self.branch = remote?.branches?.first
        }
    }
}
