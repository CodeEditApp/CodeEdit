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

    let sourceControlManager: SourceControlManager
    let fromBranch: GitBranch
    @State var name: String = ""

    var body: some View {
        NavigationStack {
            TextField("New Branch Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
        .navigationTitle("Create Branch from \(fromBranch.name)")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createBranch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .frame(width: 300)
    }

    func createBranch() {
        Task {
            do {
                try await sourceControlManager.newBranch(name: name, from: fromBranch)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to create branch", error: error)
            }
        }
    }
}
