//
//  BitbucketAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
let bitbucketWebURL = "https://bitbucket.org/"

struct BitbucketAccount {
    let configuration: BitbucketTokenConfiguration

    init(_ config: BitbucketTokenConfiguration = BitbucketTokenConfiguration()) {
        configuration = config
    }
}

extension Router {
    internal var URLRequest: Foundation.URLRequest? {
        request()
    }
}
