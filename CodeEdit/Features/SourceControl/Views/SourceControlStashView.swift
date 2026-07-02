//
//  SourceControlAddRemoteView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import SwiftUI

struct SourceControlStashView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @EnvironmentObject var sourceControlViewModel: SourceControlViewModel
    @Environment(\.dismiss)
    private var dismiss

    @State private var message: String = ""
    @State private var applyStashAfterOperation: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("", text: $message, prompt: Text("Message (optional)"), axis: .vertical)
                        .labelsHidden()
                        .lineLimit(3...3)
                        .contentShape(Rectangle())
                        .frame(height: 48)
                } header: {
                    Text("Stash Changes")
                    Group {
                        if sourceControlViewModel.pullSheetIsPresented
                            || sourceControlViewModel.switchToBranch != nil {
                            Text("Your local repository has uncommitted changes that need to be stashed " +
                                 "before you can continue. Enter a description for your changes.")
                        } else {
                            Text("Enter a description for your stashed changes so you can reference them later. " +
                                 "Stashes will appear in the Source Control navigator for your repository.")
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                }
                if sourceControlViewModel.pullSheetIsPresented
                    || sourceControlViewModel.switchToBranch != nil {
                    Section {
                        Toggle("Apply stash after operation", isOn: $applyStashAfterOperation)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .onSubmit(submit)
            HStack {
                Spacer()
                Button {
                    message = ""
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 56)
                }
                Button {
                    submit()
                } label: {
                        Text(
                            sourceControlViewModel.pullSheetIsPresented
                            ? "Stash and Pull"
                            : sourceControlViewModel.switchToBranch != nil
                            ? "Stash and Switch"
                            : "Stash"
                        )
                        .frame(minWidth: 56)
                    }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 500)
    }

    func submit() {
        Task {
            do {
                try await sourceControlManager.stashChanges(message: message)
                message = ""

                if sourceControlViewModel.pullSheetIsPresented
                    || sourceControlViewModel.switchToBranch != nil {
                    if sourceControlViewModel.pullSheetIsPresented {
                        try await sourceControlManager.pull(
                            remote: sourceControlViewModel.operationRemote?.name,
                            branch: sourceControlViewModel.operationBranch?.name,
                            rebase: sourceControlViewModel.operationRebase
                        )
                    }

                    if let branch = sourceControlViewModel.switchToBranch {
                        try await sourceControlManager.checkoutBranch(branch: branch)
                    }

                    if applyStashAfterOperation {
                        guard let lastStashEntry = sourceControlManager.stashEntries.first else {
                            throw NSError(
                                domain: "SourceControl",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Could not find last stash"]
                            )
                        }
                        try await sourceControlManager.applyStashEntry(stashEntry: lastStashEntry)
                    }

                    sourceControlViewModel.operationRemote = nil
                    sourceControlViewModel.operationBranch = nil
                    sourceControlViewModel.pullSheetIsPresented = false
                    sourceControlViewModel.switchToBranch = nil
                }

                dismiss()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to stash changes", error: error)
            }
        }
    }
}
