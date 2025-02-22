//
//  CommitListItemView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/2023.
//

import SwiftUI
import SwiftGitX

struct CommitListItemView: View {

    var commit: Commit
    var showRef: Bool
    var width: CGFloat

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .foregroundColor(avatarColor)
            .frame(width: 32, height: 32)
    }

    private func generateAvatarHash() -> String {
        let hash = commit.author.email.md5(trim: true, caseSensitive: false)
        return "\(hash)?d=404&s=64" // send 404 if no image available, image size 64x64 (32x32 @2x)
    }

    private var avatarColor: Color {
        let hash = generateAvatarHash().hash
        switch hash % 12 {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        case 3: return .green
        case 4: return .mint
        case 5: return .teal
        case 6: return .cyan
        case 7: return .blue
        case 8: return .indigo
        case 9: return .purple
        case 10: return .brown
        case 11: return .pink
        default: return .teal
        }
    }

    @Environment(\.openURL)
    private var openCommit

    init(commit: Commit, showRef: Bool) {
        self.commit = commit
        self.showRef = showRef
        self.width = 0
    }

    init(commit: Commit, showRef: Bool, width: CGFloat) {
        self.commit = commit
        self.showRef = showRef
        self.width = width
    }

    var body: some View {
        HStack(alignment: .top) {
            if width > 360 {
                AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(generateAvatarHash())")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 32, height: 32)
                            .help(commit.author.name)
                    } else if phase.error != nil {
                        defaultAvatar
                            .help(commit.author.name)
                    } else {
                        defaultAvatar
                            .help(commit.author.name)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(commit.author.name)
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                    // TODO: Migrate to SwiftGitX
//                    if showRef {
//                        if !commit.branches.isEmpty {
//                            HStack {
//                                ForEach(commit.refs, id: \.self) { ref in
//                                    HStack(spacing: 2.5) {
//                                        Image.branch
//                                            .imageScale(.small)
//                                            .foregroundColor(.secondary)
//                                            .help(ref)
//                                        Text(ref)
//                                    }
//                                    .font(.system(size: 10))
//                                    .frame(height: 13)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 3)
//                                            .padding(.vertical, -1)
//                                            .padding(.leading, -2.5)
//                                            .padding(.trailing, -4)
//                                            .foregroundColor(Color(nsColor: .quaternaryLabelColor))
//                                    )
//                                    .padding(.trailing, 2.5)
//                                }
//                            }
//                        }
//
//                        if !commit.tag.isEmpty {
//                            HStack(spacing: 2.5) {
//                                Image(systemName: "tag")
//                                    .imageScale(.small)
//                                    .foregroundColor(.primary)
//                                    .help(commit.tag)
//                                Text(commit.tag)
//                            }
//                            .font(.system(size: 10))
//                            .frame(height: 13)
//                            .background(
//                                RoundedRectangle(cornerRadius: 3)
//                                    .padding(.vertical, -1)
//                                    .padding(.leading, -2.5)
//                                    .padding(.trailing, -4)
//                                    .foregroundColor(Color(nsColor: .purple).opacity(0.2))
//                            )
//                            .padding(.trailing, 2.5)
//                        }
//                    }
                }

                Text(commit.message)
                    .font(.system(size: 11))
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text(commit.id.abbreviated)
                    .font(.system(size: 10, design: .monospaced))
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .padding(.vertical, -1)
                            .padding(.horizontal, -2.5)
                            .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                    )
                    .padding(.trailing, 2.5)
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
                Button("Copy Identifier") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(commit.id.hex, forType: .string)
                }
                Button("Email \(commit.author.name)...") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.author.email]
                    service?.perform(withItems: [])
                }
                Divider()
            }
            Group {
                Button("Tag \(commit.id.hex)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("New Branch from \(commit.id.hex)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Cherry-Pick \(commit.id.hex)...") {}
                    .disabled(true) // TODO: Implementation Needed
            }

            // TODO: Migrate to SwiftGitx
//            Group {
//                Divider()
//                if let commitRemoteURL = commit.commitBaseURL?.absoluteString {
//                    Button("View on \(commit.remoteString)...") {
//                        let commitURL = "\(commitRemoteURL)/\(commit.id.hex)"
//                        openCommit(URL(string: commitURL)!)
//                    }
//                    Divider()
//                }
//                Button("Check Out \(commit.id.hex)...") {}
//                    .disabled(true) // TODO: Implementation Needed
//                Divider()
//                Button("History Editor Help") {}
//                    .disabled(true) // TODO: Implementation Needed
//            }
        }
    }
}
