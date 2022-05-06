//
//  GitType.swift
//  
//
//  Created by Nanashi Li on 2022/05/06.
//

import Foundation

// swiftlint:disable identifier_name
public enum GitType: String, Codable {
    case M = "M"
    case Unknown = "??"
    case T = "T"
    case A = "A"
    case D = "D"
    case R = "R"
    case C = "C"
    case U = "U"
}
