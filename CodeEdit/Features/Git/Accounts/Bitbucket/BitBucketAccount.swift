//
//  BitBucketAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

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
