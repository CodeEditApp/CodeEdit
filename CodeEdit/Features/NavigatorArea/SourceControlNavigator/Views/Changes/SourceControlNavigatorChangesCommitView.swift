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
    @State private var details: String = ""
    @State private var ammend: Bool = false
    @State private var showDetails: Bool = false
    @State private var isCommiting: Bool = false

    var allFilesStaged: Bool {
        let listSet = Set(sourceControlManager.changedFiles.map { $0.id })
        let findListSet = Set(sourceControlManager.filesToCommit)
        return listSet.isSubset(of: findListSet)
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                PaneTextField(
                    "Commit message (required)",
                    text: $message
                )
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if showDetails {
                        VStack {
                            TextField(
                                "Detailed description",
                                text: $details,
                                axis: .vertical
                            )
                            .textFieldStyle(.plain)
                            .controlSize(.small)
                            .lineLimit(3...5)

                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3.5)
                        .overlay(alignment: .top) {
                            VStack {
                                Divider()
                            }
                        }
                    }
                }
                VStack {
                    if showDetails {
                        VStack(spacing: 8) {
                            Toggle(isOn: $ammend) {
                                Text("Amend")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                        }
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                HStack(spacing: 8) {
                    Button {
                        sourceControlManager.filesToCommit = allFilesStaged
                        ? []
                        : sourceControlManager.changedFiles.map { $0.id }
                    } label: {
                        Text(allFilesStaged ? "Unstage All" : "Stage All")
                            .frame(maxWidth: .infinity)
                    }
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
                .padding(.top, 8)
            }
            .transition(.move(edge: .top))
            .onChange(of: message) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    showDetails = !message.isEmpty
                }
            }
            .padding(.horizontal, 10)
            Divider()
        }
    }
}
