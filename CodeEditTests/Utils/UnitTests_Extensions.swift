//
//  UnitTests_Extensions.swift
//  CodeEditModules/CodeEditUtilsTests
//
//  Created by Lukas Pistrol on 01.05.22.
//

import Foundation
import SwiftUI
import XCTest
import CodeEditCore
import CodeEditSettings
@testable import CodeEdit

final class CodeEditUtilsExtensionsUnitTests: XCTestCase {

    // MARK: - COLOR + HEX

    func testColorConversionFromHEXString() throws {
        let colorString = "#123456"
        let color = Color(hex: colorString)

        XCTAssertEqual(colorString, color.hexString)
    }

    func testNSColorConversionFromHEXString() throws {
        let colorString = "#123456"
        let color = NSColor(hex: colorString)

        XCTAssertEqual(colorString, color.hexString)
    }

    func testColorConversionFromHEXInt() throws {
        let colorInt = 0x123456
        let color = Color(hex: colorInt)

        XCTAssertEqual(colorInt, color.hex)
    }

    func testNSColorConversionFromHEXInt() throws {
        let colorInt = 0x123456
        let color = NSColor(hex: colorInt)

        XCTAssertEqual(colorInt, color.hex)
    }

    func testColorConversionAlphaValue() throws {
        let alpha = 0.25
        let color = Color(hex: "#123456", alpha: alpha)

        XCTAssertEqual(alpha, color.alphaComponent)
    }

    func testNSColorConversionAlphaValue() throws {
        let alpha = 0.25
        let color = NSColor(hex: "#123456", alpha: alpha)

        XCTAssertEqual(alpha, color.alphaComponent)
    }

    // MARK: - STRING + VALID FILE NAME

    func testValidFileName() {
        let validCases = [
            "hello world",
            "newSwiftFile.swift",
            "documento_español.txt",
            "dokument_deutsch.pdf",
            "rapport_français.docx",
            "レポート_日本語.xlsx",
            "отчет_русский.pptx",
            "보고서_한국어.txt",
            "文件_中文.pdf",
            "dokument_svenska.txt",
            "relatório_português.docx",
            "relazione_italiano.pdf",
            "file_with_emoji_😊.txt",
            "emoji_report_📄.pdf",
            "archivo_con_emoji_🌟.docx",
            "文件和表情符号_🚀.txt",
            "rapport_avec_emoji_🎨.pptx",
            // 255 characters (exactly the maximum)
            String((0..<255).map({ _ in "abcd".randomElement() ?? Character("") }))
        ]

        for validCase in validCases {
            XCTAssertTrue(validCase.isValidFilename, "Detected invalid case \"\(validCase)\", should be valid.")
        }
    }

    func testInvalidFileName() {
        // The only limitations for macOS file extensions is no ':' and no NULL characters and 255 UTF16 char limit.
        let invalidCases = [
            "",
            ":",
            "\0",
            "Hell\0 World!",
            "export:2024-04-12.txt",
            // 256 characters (1 too long)
            String((0..<256).map({ _ in "abcd".randomElement() ?? Character("") }))
        ]

        for invalidCase in invalidCases {
            XCTAssertFalse(invalidCase.isValidFilename, "Detected valid case \"\(invalidCase)\", should be invalid.")
        }
    }

    // MARK: - STRING + ESCAPED

    func testEscapeQuotes() {
        let string = #"this/is/"a path/Hello "world"#
        XCTAssertEqual(string.escapedQuotes(), #"this/is/\"a path/Hello \"world"#)
    }

    func testEscapeQuotesForAlreadyEscapedString() {
        let string = #"this/is/"a path/Hello \"world"#
        XCTAssertEqual(string.escapedQuotes(), #"this/is/\"a path/Hello \"world"#)
    }

    func testEscapedDirectory() {
        let path = #"/Hello World/ With Spaces/ And " Characters "#
        XCTAssertEqual(path.escapedDirectory(), #""/Hello World/ With Spaces/ And \" Characters ""#)
    }

    // MARK: - URL + Contains

    func testURLContainsSubPath() {
        XCTAssertTrue(URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/file.txt")))
        XCTAssertFalse(URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/")))
        XCTAssertFalse(URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/")))
        XCTAssertTrue(URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/Folder")))
    }

    func testURLSharedComponentsCount() {
        // URL Treats the leading `/` as a component, so these all appear to have + 1 but are correct.
        XCTAssertEqual(
            URL(filePath: "/Users/Bob/Desktop").sharedComponents(URL(filePath: "/Users/Bob/Desktop/file.txt")),
            4
        )
        XCTAssertEqual(
            URL(filePath: "/Users/Bob/Desktop").sharedComponents(URL(filePath: "/Users/Bob/Desktop/")),
            4
        )
        XCTAssertEqual(
            URL(filePath: "/Users/Bob/Desktop").sharedComponents(URL(filePath: "/Users/Bob/")),
            3
        )
        XCTAssertEqual(
            URL(filePath: "/Users/Bob/Desktop").sharedComponents(URL(filePath: "/Users/Bob/Desktop/Folder")),
            4
        )

        XCTAssertEqual(
            URL(filePath: "/Users/Bob/Desktop").sharedComponents(URL(filePath: "/Some Other/ Path ")),
            1
        )
    }
}
