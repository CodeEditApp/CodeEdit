//
//  SourceControlAddRemoteView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import SwiftUI

struct SourceControlStashView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
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
                        if sourceControlManager.pullSheetIsPresented {
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
                if sourceControlManager.pullSheetIsPresented {
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
                Button("Cancel") {
                    message = ""
                    dismiss()
                }
                Button(sourceControlManager.pullSheetIsPresented ? "Stash and Pull" : "Stash", action: submit)
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

                if sourceControlManager.pullSheetIsPresented {
                    try await sourceControlManager.pull(
                        remote: sourceControlManager.operationRemote?.name ?? nil,
                        branch: sourceControlManager.operationBranch?.name ?? nil,
                        rebase: sourceControlManager.operationRebase
                    )
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
                    sourceControlManager.operationRemote = nil
                    sourceControlManager.operationBranch = nil
                    sourceControlManager.pullSheetIsPresented = false
                }

                dismiss()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to stash changes", error: error)
            }
        }
    }
}
