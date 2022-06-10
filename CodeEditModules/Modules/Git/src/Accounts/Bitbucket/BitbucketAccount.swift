//
//  BitbucketAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
// swiftlint:disable missing_docs
public let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
public let bitbucketWebURL = "https://bitbucket.org/"

public struct BitbucketAccount {
    public let configuration: BitbucketTokenConfiguration

    public init(_ config: BitbucketTokenConfiguration = BitbucketTokenConfiguration()) {
        configuration = config
    }
}

extension Router {
    internal var URLRequest: Foundation.URLRequest? {
        request()
    }
}
