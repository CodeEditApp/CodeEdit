//
//  SourceControlNavigatorSyncView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import SwiftUI

struct SourceControlNavigatorSyncView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var isSyncing: Bool = false

    var body: some View {
        VStack {
            Button {
                self.sync()
            } label: {
                HStack {
                    Spacer()
                    if isSyncing {
                        Text("Syncing...")
                    } else {
                        Label(
                            title,
                            systemImage: icon
                        )
                    }
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSyncing)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }

    var title: String {
        if sourceControlManager.numberOfUnsyncedCommits > 0 {
            return "Sync Changes \(sourceControlManager.numberOfUnsyncedCommits)"
        }

        return "Publish Branch"
    }

    var icon: String {
        if sourceControlManager.numberOfUnsyncedCommits > 0 {
            return "arrow.triangle.2.circlepath"
        }

        return "arrowshape.up.circle"
    }

    func sync() {
        Task(priority: .background) {
            self.isSyncing = true
            do {
                try await sourceControlManager.push()
            } catch {
                // TODO: Handle errors
            }
            self.isSyncing = false
        }
    }
}
