//
//  SourceControlAccount.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

// SourceControlAccount is now a class in order to fix some UI bugs
class SourceControlAccount: Codable, Identifiable, Hashable, ObservableObject {
    internal init(
        id: String,
        name: String,
        description: String,
        provider: Provider,
        serverURL: String,
        urlProtocol: Bool,
        sshKey: String,
        isTokenValid: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.provider = provider
        self.serverURL = serverURL
        self.urlProtocol = urlProtocol
        self.sshKey = sshKey
        self.isTokenValid = isTokenValid
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.provider = try container.decode(Provider.self, forKey: .provider)
        self.serverURL = try container.decode(String.self, forKey: .serverURL)
        self.urlProtocol = try container.decode(Bool.self, forKey: .urlProtocol)
        self.sshKey = try container.decode(String.self, forKey: .sshKey)
        self.isTokenValid = try container.decode(Bool.self, forKey: .isTokenValid)
    }

    var id: String
    var name: String
    @Published var description: String
    var provider: Provider
    var serverURL: String
    // TODO: Should we use an enum instead of a boolean here:
    // If true we use the HTTP protocol else if false we use SSH
    var urlProtocol: Bool
    var sshKey: String
    var isTokenValid: Bool

    enum Provider: Codable, CaseIterable, Identifiable {
        case bitbucketCloud
        case bitbucketServer
        case github
        case githubEnterprise
        case gitlab
        case gitlabSelfHosted

        var id: String {
            switch self {
            case .bitbucketCloud:
                return "bitbucketCloud"
            case .bitbucketServer:
                return "bitbucketServer"
            case .github:
                return "github"
            case .githubEnterprise:
                return "githubEnterprise"
            case .gitlab:
                return "gitlab"
            case .gitlabSelfHosted:
                return "gitlabSelfHosted"
            }
        }

        var name: String {
            switch self {
            case .bitbucketCloud:
                return "BitBucket Cloud"
            case .bitbucketServer:
                return "BitBucket Server"
            case .github:
                return "GitHub"
            case .githubEnterprise:
                return "GitHub Enterprise"
            case .gitlab:
                return "GitLab"
            case .gitlabSelfHosted:
                return "GitLab Self-hosted"
            }
        }

        var baseURL: URL? {
            switch self {
            case .bitbucketCloud:
                return URL(string: "https://www.bitbucket.com/")!
            case .bitbucketServer:
                return nil
            case .github:
                return URL(string: "https://www.github.com/")!
            case .githubEnterprise:
                return nil
            case .gitlab:
                return URL(string: "https://www.gitlab.com/")!
            case .gitlabSelfHosted:
                return nil
            }
        }

        var iconName: String {
            switch self {
            case .bitbucketCloud:
                return "BitBucketIcon"
            case .bitbucketServer:
                return "BitBucketIcon"
            case .github:
                return "GitHubIcon"
            case .githubEnterprise:
                return "GitHubIcon"
            case .gitlab:
                return "GitLabIcon"
            case .gitlabSelfHosted:
                return "GitLabIcon"
            }
        }

        var authHelpURL: URL {
            switch self {
            case .bitbucketCloud:
                return URL(string: "https://support.atlassian.com/bitbucket-cloud/docs/app-passwords/")!
            case .bitbucketServer:
                return URL(string:
                    "https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html")!
            case .github:
                return URL(string: "https://github.com/settings/tokens/new")!
            case .githubEnterprise:
                return URL(string: "https://github.com/settings/tokens/new")!
            case .gitlab:
                return URL(string: "https://gitlab.com/-/profile/personal_access_tokens")!
            case .gitlabSelfHosted:
                return URL(string: "https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html")!
            }
        }

        var authType: AuthType {
            switch self {
            case .bitbucketCloud:
                return .password
            case .bitbucketServer:
                return .token
            case .github:
                return .token
            case .githubEnterprise:
                return .token
            case .gitlab:
                return .token
            case .gitlabSelfHosted:
                return .token
            }
        }
    }

    enum AuthType {
        case token
        case password
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case provider
        case serverURL
        case urlProtocol
        case sshKey
        case isTokenValid
    }

    static func == (lhs: SourceControlAccount, rhs: SourceControlAccount) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.provider == rhs.provider &&
            lhs.serverURL == rhs.serverURL &&
            lhs.urlProtocol ==  rhs.urlProtocol &&
            lhs.sshKey ==  rhs.sshKey &&
            lhs.isTokenValid == rhs.isTokenValid
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(provider, forKey: .provider)
        try container.encode(serverURL, forKey: .serverURL)
        try container.encode(urlProtocol, forKey: .urlProtocol)
        try container.encode(sshKey, forKey: .sshKey)
        try container.encode(isTokenValid, forKey: .isTokenValid)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(provider)
        hasher.combine(serverURL)
        hasher.combine(urlProtocol)
        hasher.combine(sshKey)
        hasher.combine(isTokenValid)
    }
}
