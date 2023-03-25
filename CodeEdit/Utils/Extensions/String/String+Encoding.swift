//
//  String+Encoding.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.23.
//

import Foundation

extension String.Encoding: Codable {
    static var allGroups: [[String.Encoding]] {
        [
            Self.allUnicodes,
            Self.allAscii,
            Self.allLatin,
            Self.allJapanese,
            Self.allWindows,
            Self.others
        ]
    }

    static var allAscii: [String.Encoding] {
        [
            .ascii,
            .nonLossyASCII
        ]
    }

    static var allJapanese: [String.Encoding] {
        [
            .iso2022JP,
            .japaneseEUC
        ]
    }

    static var allLatin: [String.Encoding] {
        [
            .isoLatin1,
            .isoLatin2,
            .macOSRoman
        ]
    }

    static var allUnicodes: [String.Encoding] {
        [
            .utf8,
            .utf16,
            .utf16BigEndian,
            .utf16LittleEndian,
            .utf32,
            .utf32BigEndian,
            .utf32LittleEndian
        ]
    }

    static var allWindows: [String.Encoding] {
        [
            .windowsCP1250,
            .windowsCP1251,
            .windowsCP1252,
            .windowsCP1253,
            .windowsCP1254
        ]
    }

    static var others: [String.Encoding] {
        [
            .nextstep,
            .shiftJIS,
            .symbol
        ]
    }
}
