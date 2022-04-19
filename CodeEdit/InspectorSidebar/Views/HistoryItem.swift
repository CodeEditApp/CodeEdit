//
//  HistoryItem.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import GitClient

struct HistoryItem: View {

    var commit: Commit

    @State var showPopup: Bool = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }

    @Environment(\.openURL) var openCommit

    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(commit.author)
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                    Text(commit.message)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(commit.hash)
                        .font(.system(size: 10))
                        .background(RoundedRectangle(cornerRadius: 3)
                            .padding(.trailing, -5)
                            .padding(.leading, -5)
                            .foregroundColor(Color("HistoryInspectorHash")))
                        .padding(.trailing, 5)
                    Text(dateFormatter.string(from: commit.date))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .onTapGesture {
            showPopup.toggle()
        }
        .popover(isPresented: $showPopup, arrowEdge: .leading) {
          PopoverView(commit: commit)
        }
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
                Button("View on GitHub...") {
                    /**
                     TODO: fetch the users username from git account also check
                     user has a github account attached to the editor
                     */
                    let commitURL = "https://github.com/CodeEditApp/CodeEdit/commit/\(commit.commitHash)"
                    openCommit(URL(string: commitURL)!)
                }
                Divider()
                Button("Check Out \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Divider()
                Button("History Editor Help") {}
                    .disabled(true) // TODO: Implementation Needed
            }
        }
    }
}
