//
//  SourceControlPullView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/28/24.
//

import SwiftUI

struct SourceControlPullView: View {
    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject var sourceControlManager: SourceControlManager

    func submit() {
        Task {
            do {
                if !sourceControlManager.changedFiles.isEmpty {
                    sourceControlManager.stashSheetIsPresented = true
                } else {
                    try await sourceControlManager.pull(
                        remote: sourceControlManager.operationRemote?.name ?? nil,
                        branch: sourceControlManager.operationBranch?.name ?? nil,
                        rebase: sourceControlManager.operationRebase
                    )
                    dismiss()
                }
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to pull", error: error)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    RemoteBranchPicker(
                        branch: $sourceControlManager.operationBranch,
                        remote: $sourceControlManager.operationRemote,
                        onSubmit: submit,
                        canCreateBranch: false
                    )
                } header: {
                    Text("Pull remote changes from")
                }
                Section {
                    Toggle("Rebase local changes onto upstream changes", isOn: $sourceControlManager.operationRebase)
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
        .frame(minWidth: 500)
    }
}
