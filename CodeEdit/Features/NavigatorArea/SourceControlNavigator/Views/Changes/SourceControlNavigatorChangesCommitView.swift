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
            VStack(spacing: 6) {
                SidebarTextField(
                    "Commit message (required)",
                    text: $message
                )
                Menu(isCommiting ? "Committing..." : "Commit") {
                    Button("Commit and Push...") {
                        print("Commit and Push...")
                    }
                } primaryAction: {
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
                }
                .disabled(
                    message.isEmpty ||
                    sourceControlManager.filesToCommit.isEmpty ||
                    isCommiting
                )
            }
            .padding(.horizontal, 8)
            Divider()
        }
    }
}
