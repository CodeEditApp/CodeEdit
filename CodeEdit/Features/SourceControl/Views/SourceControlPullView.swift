//
//  SourceControlPullView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/28/24.
//

import SwiftUI

struct SourceControlPullView: View {
    @EnvironmentObject var scm: SourceControlManager

    @State var branch: GitBranch?
    @State var remote: GitRemote?
    @State var rebase: Bool = false

    func submit() {
        Task {
            do {
                try await scm.pull(remote: remote?.name ?? nil, branch: branch?.name ?? nil, rebase: rebase)
            } catch {
                await scm.showAlertForError(title: "Failed to pull", error: error)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    RemoteBranchPicker(
                        branch: $branch,
                        remote: $remote,
                        onSubmit: submit,
                        canCreateBranch: false
                    )
                } header: {
                    Text("Pull remote changes from")
                }
                Section {
                    Toggle("Rebase local changes onto upstream changes", isOn: $rebase)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 56)
                }
                Button(action: submit) {
                    Text("Pull")
                        .frame(minWidth: 56)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 480)
    }

    @Environment(\.dismiss) private var dismiss
}
