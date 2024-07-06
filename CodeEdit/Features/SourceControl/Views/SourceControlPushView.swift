//
//  SourceControlPushView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/26/24.
//

import SwiftUI

struct SourceControlPushView: View {
    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject var sourceControlManager: SourceControlManager

    func submit() {
        Task {
            do {
                try await sourceControlManager.push(
                    remote: sourceControlManager.operationRemote?.name ?? nil,
                    branch: sourceControlManager.operationBranch?.name ?? nil,
                    setUpstream: sourceControlManager.currentBranch?.upstream == nil
                )
                dismiss()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to push", error: error)
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
                        canCreateBranch: true
                    )
                } header: {
                    Text("Push local changes to")
                }
                Section {
                    Toggle("Force", isOn: $sourceControlManager.operationForce)
                    Toggle("Include Tags", isOn: $sourceControlManager.operationIncludeTags)
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
                    Text("Push")
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
