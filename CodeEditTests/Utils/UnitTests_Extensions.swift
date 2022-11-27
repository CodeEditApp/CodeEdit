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

    // MARK: - STRING + REMOVING OCCURRENCIES

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

}
