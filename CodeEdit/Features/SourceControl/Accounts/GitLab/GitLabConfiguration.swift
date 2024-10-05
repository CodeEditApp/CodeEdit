//
//  GitLabConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct GitLabTokenConfiguration: GitRouterConfiguration {
    let provider = SourceControlAccount.Provider.gitlab
    var apiEndpoint: String?
    var accessToken: String?
    let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    init(_ token: String? = nil, url: String? = nil) {
        apiEndpoint = url ?? provider.apiURL?.absoluteString
        accessToken = token
    }
}

struct GitLabPrivateTokenConfiguration: GitRouterConfiguration {
    let provider = SourceControlAccount.Provider.gitlab
    var apiEndpoint: String?
    var accessToken: String?
    let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    init(_ token: String? = nil, url: String? = nil) {
        apiEndpoint = url ?? provider.apiURL?.absoluteString
        accessToken = token
    }

    var accessTokenFieldName: String {
        "private_token"
    }
}
