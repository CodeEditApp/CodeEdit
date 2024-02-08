//
//  SourceControlNavigatorAddTagView.swift
//  CodeEdit
//
//  Created by Johnathan Baird on 2/8/24.
//
import SwiftUI
struct SourceControlNavigatorNewTagView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @Environment(\.dismiss)
    var dismiss

    @State var name: String = ""
    let commitHash: String
    @State var message: String = ""

    func submit() {
        Task {
            do {
                try await sourceControlManager.newTag(tagName: name, commitHash: commitHash, message: message)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await sourceControlManager.showAlertForError(
                    title: "Failed to create tag",
                    error: error
                )
            }
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                Form {
                    Section {
                        LabeledContent("Revision:", value: commitHash)
                        TextField("Tag:", text: $name)
                        TextField("Message:", text: $message)
                    } header: {
                        Text("Create a new tag from revision")
                    }
                }
                //.formStyle(.grouped)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .onSubmit { submit() }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    Button("Create") {
                        submit()
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
