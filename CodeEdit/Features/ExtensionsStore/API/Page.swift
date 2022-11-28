//
//  Page.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

struct Page<T: Codable>: Codable {
    var items: [T]

    var metadata: Metadata

    struct Metadata: Codable {
        var total: Int
        var per: Int
        var page: Int
    }
}
