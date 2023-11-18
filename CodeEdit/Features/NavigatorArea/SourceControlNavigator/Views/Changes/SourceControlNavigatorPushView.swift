//
//  SourceControlNavigatorPushView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import SwiftUI

struct SourceControlNavigatorPushView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var isPushing: Bool = false

    var body: some View {
        HStack {
            Label(title: {
                if sourceControlManager.numberOfUnpushedCommits > 0 {
                    Text("\(sourceControlManager.numberOfUnpushedCommits) ahead")
                } else {
                    Text("Current branch untracked")
                }
            }, icon: {
                Image(systemName: "arrow.up.arrow.down")
            })
            Spacer()
            Button {
                self.push()
            } label: {
                if isPushing {
                    Text("Pushing...")
                } else {
                    Text("Push")
                }
            }
            .disabled(isPushing)
        }
    }

    func push() {
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
