//
//  GitType.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation

enum GitType: String, Codable {
    case modified = "M"
    case unknown = "??"
    case fileTypeChange = "T"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case updatedUnmerged = "U"

    var description: String {
        switch self {
        case .modified: return "M"
        case .unknown: return "?"
        case .fileTypeChange: return "T"
        case .added: return "A"
        case .deleted: return "D"
        case .renamed: return "R"
        case .copied: return "C"
        case .updatedUnmerged: return "U"
        }
    }
}
