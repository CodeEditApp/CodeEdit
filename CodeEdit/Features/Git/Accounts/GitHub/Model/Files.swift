//
//  Files.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
typealias Files = [String: File]

class File: Codable {
    private(set) var id: Int = -1
    var rawURL: URL?
    var filename: String?
    var type: String?
    var language: String?
    var size: Int?
    var content: String?

    enum CodingKeys: String, CodingKey {
        case rawURL = "raw_url"
        case filename
        case type
        case language
        case size
        case content
    }
}
