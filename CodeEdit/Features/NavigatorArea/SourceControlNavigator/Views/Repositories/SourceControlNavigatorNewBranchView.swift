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

    var body: some View {
        if let branch = fromBranch ?? sourceControlManager.currentBranch {
            NavigationStack {
                TextField("New Branch Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            .navigationTitle("Create Branch from \(branch.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
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
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
                }
            }
            .frame(width: 300)
        }
    }
}
