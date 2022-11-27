//
//  PopoverView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import SwiftUI

struct PopoverView: View {

    private var commit: Commit

    init(commit: Commit) {
        self.commit = commit
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(generateAvatarHash())")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)
                        } else if phase.error != nil {
                            defaultAvatar
                        } else {
                            defaultAvatar
                        }
                    }

                    VStack(alignment: .leading) {
                        Text(commit.author)
                            .fontWeight(.bold)
                        Text(commit.date.formatted(date: .long, time: .shortened))
                    }

                    Spacer()

                    Text(commit.hash)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Text(commitDetails())
                    .frame(alignment: .leading)
            }
            .padding(.horizontal)

            Divider()
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                // TODO: Implementation Needed
                ActionButton("Show Commit", systemImage: "clock") {}
                    .disabled(true)
                // TODO: Implementation Needed
                ActionButton("Open in Code Review", systemImage: "arrow.left.arrow.right") {}
                    .disabled(true)
                ActionButton("Email \(commit.author)", systemImage: "envelope") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                    service?.perform(withItems: [])
                }
            }
            .padding(.horizontal, 6)
        }
        .padding(.top)
        .padding(.bottom, 5)
        .frame(width: 310)
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .foregroundColor(avatarColor)
            .frame(width: 42, height: 42)
    }

    private struct ActionButton: View {

        private var title: String
        private var image: String
        private var action: () -> Void

        @State
        private var isHovering: Bool = false

        @Environment(\.isEnabled) private var isEnabled

        init(_ title: String, systemImage: String, action: @escaping () -> Void) {
            self.title = title
            self.image = systemImage
            self.action = action
        }

        var body: some View {
            Button {
                action()
            } label: {
                Label(title, systemImage: image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(isHovering && isEnabled ? .white : .primary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                EffectView.selectionBackground(isHovering && isEnabled)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }

    private func commitDetails() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if commit.authorEmail != commit.commiterEmail {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return "\(commit.message)\n\n\(coAuthDetail())".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func coAuthDetail() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return ""
        } else if commit.authorEmail != commit.commiterEmail {
            return "Co-authored-by: \(commit.commiter)\n<\(commit.commiterEmail)>"
        }
        return ""
    }

    private func generateAvatarHash() -> String {
        let hash = commit.authorEmail.md5(trim: true, caseSensitive: false)
        return "\(hash)?d=404&s=84" // send 404 if no image available, image size 84x84 (42x42 @2x)
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
}
