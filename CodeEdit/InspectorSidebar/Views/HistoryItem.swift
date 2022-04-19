//
//  HistoryItem.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import GitClient

extension Date {
    func relativeStringToNow() -> String {
        if Calendar.current.isDateInToday(self) ||
            Calendar.current.isDateInYesterday(self) {
            let style = RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .abbreviated,
                locale: .current,
                calendar: .current,
                capitalizationContext: .standalone
            )

            return self.formatted(style)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        return formatter.string(from: self)
    }
}

struct HistoryItem: View {

    var commit: Commit

    @Binding var selection: Commit?

    private var showPopup: Binding<Bool> {
        Binding<Bool> {
            return selection == commit
        } set: { newValue in
            if newValue {
                selection = commit
            } else {
                selection = nil
            }
        }
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
                VStack(alignment: .trailing, spacing: 5) {
                    Text(commit.hash)
                        .font(.system(size: 10))
                        .background(RoundedRectangle(cornerRadius: 3)
                            .padding(.trailing, -5)
                            .padding(.leading, -5)
                            .foregroundColor(Color("HistoryInspectorHash")))
                        .padding(.trailing, 5)
                    Text(commit.date.relativeStringToNow())
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .popover(isPresented: showPopup, arrowEdge: .leading) {
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
