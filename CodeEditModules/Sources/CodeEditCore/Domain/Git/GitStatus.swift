//
//  GitType.swift
//
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation

public enum GitStatus: String, Codable, Sendable {
    case none = "."
    case modified = "M"
    case untracked = "?"
    case fileTypeChange = "T"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case unmerged = "U"

    public var description: String {
        switch self {
        case .modified: return "M"
        case .untracked: return "U"
        case .fileTypeChange: return "T"
        case .added: return "A"
        case .deleted: return "D"
        case .renamed: return "R"
        case .copied: return "C"
        case .unmerged: return "U"
        case .none: return ""
        }
    }
}
