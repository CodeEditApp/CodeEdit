//
//  SourceControlNavigatorRenameBranchView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/28/23.
//

import SwiftUI

struct SourceControlNavigatorRenameBranchView: View {
    @Environment(\.dismiss)
    var dismiss

    @State var name: String = ""
    let sourceControlManager: SourceControlManager
    let fromBranch: GitBranch?

    func submit(_ branch: GitBranch) {
        Task {
            do {
                try await sourceControlManager.renameBranch(oldName: branch.name, newName: name)
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
                        Text("Rename branch")
                        Text("All uncommited changes will be preserved on the renamed branch.")
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
                    Button("Rename") {
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
