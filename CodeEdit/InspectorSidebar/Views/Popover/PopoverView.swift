//
//  PopoverView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import SwiftUI
import GitClient
import CodeEditUI
import CodeEditUtils

struct PopoverView: View {

    var commit: Commit

    @State var onHover: Bool = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(generateAvatarHash())")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)
                        } else if phase.error != nil {
                            Image(systemName: "person.crop.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .resizable()
                                .foregroundColor(avatarColor)
                                .frame(width: 42, height: 42)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .resizable()
                                .foregroundColor(avatarColor)
                                .frame(width: 42, height: 42)
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
                .padding(.top, 10)
                .padding(.horizontal, 8)

                VStack {
                    Text(commitDetails())
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                        .padding(.horizontal, 8)
                }
            }
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("HistoryInspectorPopover")))
            .padding(12)

            VStack(alignment: .leading) {
                // TODO: Implementation Needed
                Button {} label: {
                    Label("Show Commit", systemImage: "clock")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                }
                .disabled(true)
                .buttonStyle(.plain)
                .onHover { hover in
                    onHover = hover
                }
                // TODO: Implementation Needed
                Button {} label: {
                    Label("Open in Code Review", systemImage: "arrow.left.arrow.right")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                }
                .disabled(true)
                .buttonStyle(.plain)
                .padding(.top, -3)
                .onHover { hover in
                    onHover = hover
                }
                Button {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                } label: {
                    Label("Email \(commit.author)", systemImage: "envelope")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                }
                .buttonStyle(.plain)
                .padding(.top, -3)
                .onHover { hover in
                    onHover = hover
                }
            }
            .padding(.top, -10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: 310, minHeight: 190)
    }

    private func commitDetails() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return """
                \(commit.message)
                """
        } else if commit.authorEmail != commit.commiterEmail {
            return """
                \(commit.message)
                """
        } else {
            return """
                \(commit.message)

                \(coAuthDetail())
                """
        }
    }

    private func coAuthDetail() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return ""
        } else if commit.authorEmail != commit.commiterEmail {
            return """
                Co-authored-by: \(commit.commiter)
                <\(commit.commiterEmail)>
                """
        }
        return ""
    }

    private func generateAvatarHash() -> String {
        let hash = commit.authorEmail.md5()
        return "\(hash)?d=404"
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
