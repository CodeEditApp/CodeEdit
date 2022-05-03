//
//  Page.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

public struct Page<T: Codable>: Codable {
    public var items: [T]

    public var metadata: Metadata

    public struct Metadata: Codable {
        public var total: Int
        public var per: Int
        public var page: Int
    }
}
