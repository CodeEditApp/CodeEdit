//
//  BitbucketTokenConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct BitbucketTokenConfiguration: RouterConfiguration {
    var apiEndpoint: String?
    var accessToken: String?
    var refreshToken: String?
    var expirationDate: Date?
    let errorDomain = "com.codeedit.models.accounts.bitbucket"

    init(json: [String: AnyObject], url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = Date()
        expirationDate = currentDate.addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }

    init(_ token: String? = nil,
         refreshToken: String? = nil,
         expirationDate: Date? = nil,
         url: String = bitbucketBaseURL
    ) {
        apiEndpoint = url
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
