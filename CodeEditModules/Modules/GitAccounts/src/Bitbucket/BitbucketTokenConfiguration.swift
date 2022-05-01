//
//  BitbucketTokenConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct BitbucketTokenConfiguration: Configuration {
    public var apiEndpoint: String?
    public var accessToken: String?
    public var refreshToken: String?
    public var expirationDate: Date?
    public let errorDomain = "com.codeedit.models.accounts.bitbucket"

    public init(json: [String: AnyObject], url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = Date()
        expirationDate = currentDate.addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }

    public init(_ token: String? = nil,
                refreshToken: String? = nil,
                expirationDate: Date? = nil,
                url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
