//
//  SourceControlAddRemoteView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import SwiftUI

struct SourceControlAddRemoteView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @Environment(\.dismiss)
    private var dismiss

    @State private var name: String = ""
    @State private var location: String = ""

    enum FocusedField {
        case name, location
    }

    @FocusState private var focusedField: FocusedField?

    func submit() {
        Task {
            do {
                try await sourceControlManager.addRemote(name: name, location: location)
                name = ""
                location = ""
                dismiss()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to add remote", error: error)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Add Remote") {
                    TextField("Remote Name", text: $name)
                        .focused($focusedField, equals: .name)
                    TextField("Location", text: $location)
                        .focused($focusedField, equals: .location)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .onSubmit(submit)
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                    name = ""
                    location = ""
                }
                Button("Add", action: submit)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 480)
        .onAppear {
            let originExists = sourceControlManager.remotes.contains { $0.name == "origin" }

            if !originExists {
                name = "origin"
                focusedField = .location
            }
        }
    }
}
