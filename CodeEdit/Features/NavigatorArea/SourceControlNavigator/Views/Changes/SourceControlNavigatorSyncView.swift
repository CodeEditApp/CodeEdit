//
//  SourceControlNavigatorSyncView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import SwiftUI

struct SourceControlNavigatorSyncView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var isPushing: Bool = false

    var body: some View {
        VStack {
            Button {
                self.sync()
            } label: {
                HStack {
                    Spacer()
                    if isPushing {
                        Text("Pushing...")
                    } else {
                        Text(title)
                    }
                    Spacer()
                }
            }
            .disabled(isPushing)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }

    var title: String {
        if sourceControlManager.numberOfUnsyncedCommits > 0 {
            return "Push \(sourceControlManager.numberOfUnsyncedCommits) Commits"
        }

        return "Push Branch"
    }

    func sync() {
        Task(priority: .background) {
            self.isPushing = true
            do {
                try await sourceControlManager.push()
            } catch {
                await sourceControlManager.showAlertForError(title: "Failed to push", error: error)
            }
            self.isPushing = false
        }
    }
}
