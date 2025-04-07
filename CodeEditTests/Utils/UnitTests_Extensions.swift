//
//  UnitTests.swift
//  CodeEditModules/CodeEditUtilsTests
//
//  Created by Lukas Pistrol on 01.05.22.
//

import Foundation
import SwiftUI
import XCTest
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

    // MARK: - DATE + FORMATTED

    func testRelativeDateStringMinutes() throws {
        let date = Date.now.addingTimeInterval(-61)
        let string = date.relativeStringToNow(locale: Locale(identifier: "en_US"))

        XCTAssertEqual("1 min. ago", string)
    }

    func testRelativeDateStringHours() throws {
        let date = Date.now.addingTimeInterval(-3_601)
        let string = date.relativeStringToNow(locale: Locale(identifier: "en_US"))

        XCTAssertEqual("1 hr. ago", string)
    }

    func testRelativeDateStringDays() throws {
        let date = Date.now.addingTimeInterval(-86_400)
        let string = date.relativeStringToNow(locale: Locale(identifier: "en_US"))

        XCTAssertEqual("yesterday", string)
    }

    // MARK: - STRING + MD5

    func testMD5GenerationCaseSensitive() throws {
        let testString = "CodeEdit"
        let md5 = testString.md5(caseSensitive: true)

        let result = "8ba8c8fd0442f7bae4d441e2a3fda706"
        XCTAssertEqual(result, md5)
    }

    func testMD5Generation() throws {
        let testString = "CodeEdit"
        let md5 = testString.md5(caseSensitive: false)

        let result = "4cdf122ff382a2d929eddc1a63473ec1"
        XCTAssertEqual(result, md5)
    }

    // MARK: - STRING + SHA256

    func testSHA256GenerationCaseSensitive() throws {
        let testString = "CodeEdit"
        let md5 = testString.sha256(caseSensitive: true)

        let result = "52125689c088f1783e53c48db78a4fe7b3fa10b12d8fba205fcf054e5ef3789a"
        XCTAssertEqual(result, md5)
    }

    func test256Generation() throws {
        let testString = "CodeEdit"
        let md5 = testString.sha256(caseSensitive: false)

        let result = "7c3f327eab3860fc823a99623b348afbf1d7aebaec5d21289fbaeab0f6340e4a"
        XCTAssertEqual(result, md5)
    }

    // MARK: - STRING + REMOVING OCCURRENCES

    func testRemovingNewLines() throws {
        let string = "Hello, \nWorld!"
        let withoutNewLines = string.removingNewLines()

        let result = "Hello, World!"
        XCTAssertEqual(result, withoutNewLines)
    }

    func testRemovingSpaces() throws {
        let string = "Hello, World!"
        let withoutSpaces = string.removingSpaces()

        let result = "Hello,World!"
        XCTAssertEqual(result, withoutSpaces)
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
}
