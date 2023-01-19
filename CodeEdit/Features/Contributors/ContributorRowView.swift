//
//  ContributorRowView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI

struct ContributorRowView: View {

    let contributor: Contributor

    var body: some View {
        HStack {
            userImage
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contributor.name)
                        .font(.headline)
                }
                HStack(spacing: 4) {
                    ForEach(contributor.contributions, id: \.self) { item in
                        tag(item)
                    }
                }
            }
            Spacer()
            HStack(alignment: .top) {
                if let profileURL = contributor.profileURL, profileURL != contributor.gitHubURL {
                    ActionButton(url: profileURL, image: .init(systemName: "globe"))
                }
                if let gitHubURL = contributor.gitHubURL {
                    ActionButton(url: gitHubURL, image: .github)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var userImage: some View {
        AsyncImage(url: contributor.avatarURL) { image in
            image
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }

    private func tag(_ item: Contributor.Contribution) -> some View {
        Text(item.rawValue.capitalized)
            .font(.caption.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(item.color)
            .background {
                Capsule(style: .continuous)
                    .strokeBorder(lineWidth: 1.5)
                    .foregroundStyle(item.color)
                    .opacity(0.8)
            }
    }

    private struct ActionButton: View {
        @Environment(\.openURL) private var openURL
        @State private var hovering = false

        let url: URL
        let image: Image

        var body: some View {
            Button {
                openURL(url)
            } label: {
                image
                    .imageScale(.large)
                    .foregroundColor(hovering ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .onHover { hover in
                hovering = hover
            }
        }
    }
}

struct ContributorRowView_Previews: PreviewProvider {
    static var previews: some View {
        let contributor = Contributor(
            login: "lukepistrol",
            name: "Lukas Pistrol",
            avatarURLString: "https://avatars.githubusercontent.com/u/9460130?v=4",
            profile: "http://lukaspistrol.com",
            contributions: [.infra, .test, .code]
        )
        ContributorRowView(contributor: contributor)
            .frame(width: 350)
    }
}
