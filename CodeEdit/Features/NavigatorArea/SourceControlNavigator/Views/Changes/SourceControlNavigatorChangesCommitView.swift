//
//  SourceControlNavigatorChangesCommitView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/19/23.
//

import SwiftUI

struct SourceControlNavigatorChangesCommitView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var message: String = ""
    @State private var isCommiting: Bool = false

    var body: some View {
        VStack {
            VStack {
                Text("Commit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack {
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .frame(height: 60)
                .background()
                .clipShape(.rect(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                )

                Button {
                    Task {
                        self.isCommiting = true
                        do {
                            try await sourceControlManager.commit(message: message)
                            self.message = ""
                        } catch {
                            await sourceControlManager.showAlertForError(title: "Failed to commit", error: error)
                        }
                        self.isCommiting = false
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(
                            isCommiting
                            ? "Committing..."
                            : "Commit"
                        )
                        Spacer()
                    }
                }
                .disabled(
                    message.isEmpty ||
                    sourceControlManager.filesToCommit.isEmpty ||
                    isCommiting
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            Divider()
        }
    }
}
