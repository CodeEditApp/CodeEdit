//
//  ContributorsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI

struct ContributorsView: View {

    @State private var contributors: [Contributor] = []

    var body: some View {
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 70, height: 70)
            Text("Contributors")
                .font(.largeTitle)
                .fontWeight(.bold)
            ScrollView(showsIndicators: false) {
                ForEach(contributors) { contributor in
                    contributorItemView(contributor)
                }
            }
        }
        .frame(width: 350, height: 500)
        .background(.regularMaterial)
        .task {
            loadContributors()
        }
    }

    func contributorItemView(_ contributor: Contributor) -> some View {
        HStack {
            AsyncImage(url: URL(string: contributor.avatarURLString)) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(contributor.name)
                    .font(.headline)
                HStack {
                    ForEach(contributor.contributions, id: \.self) { item in
                        Text(item.rawValue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .foregroundColor(item.color)
                            }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    func showWindow(width: CGFloat, height: CGFloat) {
        ContributorsWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
    }

    func loadContributors() {
        guard let url = Bundle.main.url(
            forResource: ".all-contributorsrc",
            withExtension: nil
        ) else { return }
        do {
            let data = try Data(contentsOf: url)
            let root = try JSONDecoder().decode(ContributorsRoot.self, from: data)
            self.contributors = root.contributors
        } catch {
            print(error)
        }
    }
}

struct ContributorsView_Previews: PreviewProvider {
    static var previews: some View {
        ContributorsView()
    }
}

struct ContributorsRoot: Codable {
    var contributors: [Contributor]
}

struct Contributor: Codable, Identifiable {
    var id: String { login }
    var login: String
    var name: String
    var avatarURLString: String
    var profile: String
    var contributions: [Contribution]

    enum CodingKeys: String, CodingKey {
        case login, name, profile, contributions
        case avatarURLString = "avatar_url"
    }

    enum Contribution: String, Codable {
        case design, code, infra, test, bug, maintenance, plugin

        var color: Color {
            switch self {
            case .design: return .blue
            case .code: return .indigo
            case .infra: return .pink
            case .test: return .purple
            case .bug: return .red
            case .maintenance: return .brown
            case .plugin: return .gray
            }
        }
    }
}
