//
//  SourceControlAddRemoteView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import SwiftUI

struct SourceControlStashChangesView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @Environment(\.dismiss)
    private var dismiss

    @State private var message: String = ""

    func submit() {
        Task {
            do {
                try await sourceControlManager.stashChanges(message: message)
                message = ""
                dismiss()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to stash changes", error: error)
            }
        }
    }

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
                    Text("Enter a description for your stashed changes so you can reference them later. " +
                         "Stashes will appear in the Source Control navigator for your repository.")
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
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
                Button("Stash", action: submit)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 480)
    }
}
