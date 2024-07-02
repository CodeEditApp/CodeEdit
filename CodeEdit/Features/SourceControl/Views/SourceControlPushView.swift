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

    @EnvironmentObject var scm: SourceControlManager

    @State var branch: GitBranch?
    @State var remote: GitRemote?
    @State var force: Bool = false
    @State var includeTags: Bool = false

    func submit() {
        Task {
            do {
                try await scm.push(
                    remote: remote?.name ?? nil,
                    branch: branch?.name ?? nil,
                    setUpstream: scm.currentBranch?.upstream == nil
                )
                dismiss()
            } catch {
                await scm.showAlertForError(title: "Failed to push", error: error)
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
                        canCreateBranch: true
                    )
                } header: {
                    Text("Push local changes to")
                }
                Section {
                    Toggle("Force", isOn: $force)
                    Toggle("Include Tags", isOn: $includeTags)
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
