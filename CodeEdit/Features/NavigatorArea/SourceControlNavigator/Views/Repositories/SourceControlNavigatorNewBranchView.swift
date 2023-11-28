//
//  SourceControlNavigatorNewBranchView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/21/23.
//

import SwiftUI

struct SourceControlNavigatorNewBranchView: View {
    @Environment(\.dismiss)
    var dismiss

    @State var name: String = ""
    let sourceControlManager: SourceControlManager
    let fromBranch: GitBranch?

    func submit(_ branch: GitBranch) {
        Task {
            do {
                try await sourceControlManager.newBranch(name: name, from: branch)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await sourceControlManager.showAlertForError(
                    title: "Failed to create branch",
                    error: error
                )
            }
        }
    }

    var body: some View {
        if let branch = fromBranch ?? sourceControlManager.currentBranch {
            VStack(spacing: 0) {
                Form {
                    Section {
                        LabeledContent("From", value: branch.name)
                        TextField("To", text: $name)
                    } header: {
                        Text("Create a new branch")
                        Text(
                            "Create a branch from the current branch and switch to it. " +
                            "All uncommited changes will be preserved on the new branch. "
                        )
                    }
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .onSubmit { submit(branch) }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    Button("Create") {
                        submit(branch)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 480)
        }
    }
}
