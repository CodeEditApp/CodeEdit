//
//  GitlabConfiguration.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public let errorDomain = "com.codeedit.models.accounts.gitlab"

public struct TokenConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public let errorDomain = errorDomain

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }
}

public struct PrivateTokenConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public let errorDomain = errorDomain

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }

    public var accessTokenFieldName: String {
        return "private_token"
    }
}
