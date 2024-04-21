//
//  CommitDetailsHeaderView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/23.
//

import SwiftUI

struct CommitDetailsHeaderView: View {
    var commit: GitCommit

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .foregroundColor(avatarColor)
            .frame(width: 32, height: 32)
    }

    private func commitDetails() -> String {
        if commit.committerEmail == "noreply@github.com" {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if commit.authorEmail != commit.committerEmail {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return "\(commit.message)\n\n\(coAuthDetail())".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func coAuthDetail() -> String {
        if commit.committerEmail == "noreply@github.com" {
            return ""
        } else if commit.authorEmail != commit.committerEmail {
            return "Co-authored by: \(commit.committer)\n<\(commit.committerEmail)>"
        }
        return ""
    }

    private func generateAvatarHash() -> String {
        let hash = commit.authorEmail.md5(trim: true, caseSensitive: false)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(generateAvatarHash())")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 32, height: 32)
                            .help(commit.author)
                    } else if phase.error != nil {
                        defaultAvatar
                            .help(commit.author)
                    } else {
                        defaultAvatar
                            .help(commit.author)
                    }
                }

                VStack(alignment: .leading) {
                    Text(commit.author)
                        .fontWeight(.bold)
                    Text(commit.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(commit.hash)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .padding(.horizontal, -2.5)
                            .padding(.vertical, -1)
                            .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                    )
                    .padding(.horizontal, 2.5)
            }
            .padding(.horizontal, 16)

            Divider()

            Text(commitDetails())
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .frame(alignment: .leading)

            if !commit.body.isEmpty {
                Text(commit.body)
                    .padding(.horizontal, 16)
                    .frame(alignment: .leading)
            }
        }
    }
}
