//
//  GitlabConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct GitlabTokenConfiguration: RouterConfiguration {

    var apiEndpoint: String?
    var accessToken: String?
    let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }
}

struct PrivateTokenConfiguration: RouterConfiguration {
    var apiEndpoint: String?
    var accessToken: String?
    let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }

    var accessTokenFieldName: String {
        "private_token"
    }
}
