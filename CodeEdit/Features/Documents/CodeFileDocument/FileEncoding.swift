//
//  FileEncoding.swift
//  CodeEdit
//
//  Created by Khan Winter on 5/31/24.
//

import Foundation

enum FileEncoding: CaseIterable {
    case utf8
    case utf16BE
    case utf16LE

    var nsValue: UInt {
        switch self {
        case .utf8:
            return NSUTF8StringEncoding
        case .utf16BE:
            return NSUTF16BigEndianStringEncoding
        case .utf16LE:
            return NSUTF16LittleEndianStringEncoding
        }
    }

    init?(_ int: UInt) {
        switch int {
        case NSUTF8StringEncoding:
            self = .utf8
        case NSUTF16BigEndianStringEncoding:
            self = .utf16BE
        case NSUTF16LittleEndianStringEncoding:
            self = .utf16LE
        default:
            return nil
        }
    }
}
