//
//  CommitListItemView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/2023.
//

import SwiftUI

struct CommitListItemView: View {

    var commit: GitCommit

    @Environment(\.openURL)
    private var openCommit

    init(commit: GitCommit) {
        self.commit = commit
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(commit.author)
                    .fontWeight(.bold)
                    .font(.system(size: 11))
                Text(commit.message)
                    .font(.system(size: 11))
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text(commit.hash)
                    .font(.system(size: 10))
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .padding(.trailing, -5)
                            .padding(.leading, -5)
                            .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                    )
                    .padding(.trailing, 5)
                Text(commit.date.relativeStringToNow())
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 1)
        }
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .contextMenu {
            Group {
                Button("Copy Commit Message") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(commit.message, forType: .string)
                }
                Button("Copy Identifier") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Email \(commit.author)...") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                    service?.perform(withItems: [])
                }
                Divider()
            }
            Group {
                Button("Tag \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("New Branch from \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Cherry-Pick \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
            }
            Group {
                Divider()
                if let commitRemoteURL = commit.commitBaseURL?.absoluteString {
                    Button("View on \(commit.remoteString)...") {
                        let commitURL = "\(commitRemoteURL)/\(commit.commitHash)"
                        openCommit(URL(string: commitURL)!)
                    }
                    Divider()
                }
                Button("Check Out \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Divider()
                Button("History Editor Help") {}
                    .disabled(true) // TODO: Implementation Needed
            }
        }
    }
}
