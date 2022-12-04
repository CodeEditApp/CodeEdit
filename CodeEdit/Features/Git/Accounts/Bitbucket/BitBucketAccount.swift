//
//  BitBucketAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
let bitbucketWebURL = "https://bitbucket.org/"

struct BitBucketAccount {
    let configuration: BitBucketTokenConfiguration

    init(_ config: BitBucketTokenConfiguration = BitBucketTokenConfiguration()) {
        configuration = config
    }
}

extension GitRouter {
    internal var URLRequest: Foundation.URLRequest? {
        request()
    }
}
