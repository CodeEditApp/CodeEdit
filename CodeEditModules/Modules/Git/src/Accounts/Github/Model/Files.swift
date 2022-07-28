//
//  Files.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
// swiftlint:disable missing_docs
public typealias Files = [String: File]

open class File: Codable {
    open private(set) var id: Int = -1
    open var rawURL: URL?
    open var filename: String?
    open var type: String?
    open var language: String?
    open var size: Int?
    open var content: String?

    enum CodingKeys: String, CodingKey {
        case rawURL = "raw_url"
        case filename
        case type
        case language
        case size
        case content
    }
}
