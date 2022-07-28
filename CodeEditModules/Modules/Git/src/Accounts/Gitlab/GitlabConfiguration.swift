//
//  GitlabConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct GitlabTokenConfiguration: Configuration {

    public var apiEndpoint: String?
    public var accessToken: String?
    public let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }
}

public struct PrivateTokenConfiguration: Configuration {
    public var apiEndpoint: String?
    public var accessToken: String?
    public let errorDomain: String? = "com.codeedit.models.accounts.gitlab"

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }

    public var accessTokenFieldName: String {
        "private_token"
    }
}
