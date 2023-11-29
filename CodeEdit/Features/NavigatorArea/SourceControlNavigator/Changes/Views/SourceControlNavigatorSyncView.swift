//
//  SourceControlNavigatorSyncView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import SwiftUI

struct SourceControlNavigatorSyncView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var isLoading: Bool = false

    var body: some View {
        HStack {
            Label(title: {
                Text(
                    formatUnsyncedlabel(
                        ahead: sourceControlManager.numberOfUnsyncedCommits.ahead,
                        behind: sourceControlManager.numberOfUnsyncedCommits.behind
                    )
                )
            }, icon: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(.secondary)
            })
            Spacer()
            if sourceControlManager.numberOfUnsyncedCommits.behind > 0 {
                Button {
                    self.pull()
                } label: {
                    if isLoading {
                        Text("Pulling...")
                    } else {
                        Text("Pull")
                    }
                }
                .disabled(isLoading)
            } else if sourceControlManager.numberOfUnsyncedCommits.ahead > 0 {
                Button {
                    self.push()
                } label: {
                    if isLoading {
                        Text("Pushing...")
                    } else {
                        Text("Push")
                    }
                }
                .disabled(isLoading)
            }
        }
    }

    func pull() {
        Task(priority: .background) {
            self.isLoading = true
            do {
                try await sourceControlManager.pull()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to pull", error: error)
            }
            self.isLoading = false
        }
    }

    func push() {
        Task(priority: .background) {
            self.isLoading = true
            do {
                try await sourceControlManager.push()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to push", error: error)
            }
            self.isLoading = false
        }
    }

    func formatUnsyncedlabel(ahead: Int?, behind: Int?) -> String {
        var parts: [String] = []

        if let ahead = ahead, ahead > 0 {
            parts.append("\(ahead) ahead")
        }

        if let behind = behind, behind > 0 {
            parts.append("\(behind) behind")
        }

        return parts.joined(separator: ", ")
    }
}
