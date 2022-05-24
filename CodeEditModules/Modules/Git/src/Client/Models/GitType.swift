//
//  GitType.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation

public enum GitType: String, Codable {
    case modified = "M"
    case unknown = "??"
    case fileTypeChange = "T"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case updatedUnmerged = "U"
}
