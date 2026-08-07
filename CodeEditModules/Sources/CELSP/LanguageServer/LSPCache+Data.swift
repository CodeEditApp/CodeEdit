//
//  LSPCache+Data.swift
//  CodeEdit
//
//  Created by Abe Malla on 6/23/24.
//

import Foundation

struct NoExtraData: Hashable { }

struct CacheKey: Hashable {
    let uri: String
    let requestType: String
    let extraData: AnyHashable?

    init(uri: String, requestType: String, extraData: AnyHashable? = nil) {
        self.uri = uri
        self.requestType = requestType
        self.extraData = extraData
    }

    static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
        return lhs.uri == rhs.uri &&
            lhs.requestType == rhs.requestType &&
            lhs.extraData == rhs.extraData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
        hasher.combine(requestType)
        if let extraData = extraData {
            hasher.combine(extraData)
        }
    }
}
