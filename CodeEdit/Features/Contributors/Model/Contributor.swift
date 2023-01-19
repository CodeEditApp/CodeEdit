//
//  Contributor.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI

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

    var avatarURL: URL? {
        URL(string: avatarURLString)
    }

    var gitHubURL: URL? {
        URL(string: "https://github.com/\(login)")
    }

    var profileURL: URL? {
        URL(string: profile)
    }

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
