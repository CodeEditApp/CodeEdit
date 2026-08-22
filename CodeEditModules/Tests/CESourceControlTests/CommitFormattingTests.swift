//
//  CommitFormattingTests.swift
//  CESourceControlTests
//
//  Created by Matthijs Eikelenboom on 14/08/26.
//

import Foundation
import XCTest
@testable import CESourceControl

/// Covers the two formatting helpers the commit list relies on. They moved here with
/// `CommitListItemView` — `relativeStringToNow` renders a commit's age, `md5` builds the Gravatar
/// hash for its author — and these assertions are the ones they shipped with app-side.
final class CommitFormattingTests: XCTestCase {

    // MARK: - Date + relative string

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

    // MARK: - String + MD5

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
}
