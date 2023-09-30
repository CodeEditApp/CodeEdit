//
//  SourceControlAccount.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

struct SourceControlAccount: Codable, Identifiable, Hashable {

    var id: String
    var name: String
    var description: String
    var provider: Provider
    var serverURL: String
    // TODO: Should we use an enum instead of a boolean here:
    // If true we use the HTTP protocol else if false we use SSH
    var urlProtocol: URLProtocol
    var sshKey: String
    var isTokenValid: Bool

    enum URLProtocol: String, Codable, CaseIterable {
        case https = "HTTPS"
        case ssh = "SSH"
    }

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

        var apiURL: URL? {
            switch self {
            case .bitbucketCloud:
                return URL(string: "https://api.bitbucket.org/2.0/")!
            case .bitbucketServer:
                return nil
            case .github:
                return URL(string: "https://api.github.com/")!
            case .githubEnterprise:
                return nil
            case .gitlab:
                return URL(string: "https://gitlab.com/api/v4/")!
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
}
