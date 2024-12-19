//
//  SemanticTokenMapTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 12/14/24.
//

import XCTest
import CodeEditSourceEditor
import LanguageServerProtocol
@testable import CodeEdit

final class SemanticTokenMapTestsTests: XCTestCase {
    // Ignores the line parameter and just returns a range from the char and length for testing
    struct MockRangeProvider: SemanticTokenMapRangeProvider {
        func nsRangeFrom(line: UInt32, char: UInt32, length: UInt32) -> NSRange? {
            return NSRange(location: Int(char), length: Int(length))
        }
    }

    let testLegend: SemanticTokensLegend = .init(
        tokenTypes: [
            "include",
            "constructor",
            "keyword",
            "boolean",
            "comment",
            "number"
        ],
        tokenModifiers: [
            "declaration",
            "definition",
            "readonly",
            "async",
            "modification",
            "defaultLibrary"
        ]
    )
    var mockProvider: MockRangeProvider!

    override func setUp() async throws {
        mockProvider = await MockRangeProvider()
    }

    @MainActor
    func testOptionA() {
        let map = SemanticTokenMap(semanticCapability: .optionA(SemanticTokensOptions(legend: testLegend)))

        // Test decode modifiers
        let modifierRaw = UInt32(0b1101)
        let decodedModifiers = map.decodeModifier(modifierRaw)
        XCTAssertEqual([.declaration, .readonly, .async], decodedModifiers)

        // Test decode tokens
        let tokens = SemanticTokens(tokens: [
            SemanticToken(line: 0, char: 0, length: 1, type: 0, modifiers: 0b11),     // First two indices set
            SemanticToken(line: 0, char: 1, length: 2, type: 0, modifiers: 0b100100), // 6th and 3rd indices set
            SemanticToken(line: 0, char: 4, length: 1, type: 0b1, modifiers: 0b101),
            SemanticToken(line: 0, char: 5, length: 1, type: 0b100, modifiers: 0b1010),
            SemanticToken(line: 0, char: 7, length: 10, type: 0, modifiers: 0)
        ])
        let decoded = map.decode(tokens: tokens, using: mockProvider)
        XCTAssertEqual(decoded.count, 5, "Decoded count")

        XCTAssertEqual(decoded[0].range, NSRange(location: 0, length: 1), "Decoded range")
        XCTAssertEqual(decoded[1].range, NSRange(location: 1, length: 2), "Decoded range")
        XCTAssertEqual(decoded[2].range, NSRange(location: 4, length: 1), "Decoded range")
        XCTAssertEqual(decoded[3].range, NSRange(location: 5, length: 1), "Decoded range")
        XCTAssertEqual(decoded[4].range, NSRange(location: 7, length: 10), "Decoded range")

        XCTAssertEqual(decoded[0].capture, nil, "No Decoded Capture")
        XCTAssertEqual(decoded[1].capture, nil, "No Decoded Capture")
        XCTAssertEqual(decoded[2].capture, .include, "Decoded Capture")
        XCTAssertEqual(decoded[3].capture, .keyword, "Decoded Capture")
        XCTAssertEqual(decoded[4].capture, nil, "No Decoded Capture")

        XCTAssertEqual(decoded[0].modifiers, [.declaration, .definition], "Decoded Modifiers")
        XCTAssertEqual(decoded[1].modifiers, [.readonly, .defaultLibrary], "Decoded Modifiers")
        XCTAssertEqual(decoded[2].modifiers, [.declaration, .readonly], "Decoded Modifiers")
        XCTAssertEqual(decoded[3].modifiers, [.definition, .async], "Decoded Modifiers")
        XCTAssertEqual(decoded[4].modifiers, [], "Decoded Modifiers")
    }

    @MainActor
    func testOptionB() {
        let map = SemanticTokenMap(semanticCapability: .optionB(SemanticTokensRegistrationOptions(legend: testLegend)))

        // Test decode modifiers
        let modifierRaw = UInt32(0b1101)
        let decodedModifiers = map.decodeModifier(modifierRaw)
        XCTAssertEqual([.declaration, .readonly, .async], decodedModifiers)

        // Test decode tokens
        let tokens = SemanticTokens(tokens: [
            SemanticToken(line: 0, char: 0, length: 1, type: 0, modifiers: 0b11),     // First two indices set
            SemanticToken(line: 0, char: 1, length: 2, type: 0, modifiers: 0b100100), // 6th and 3rd indices set
            SemanticToken(line: 0, char: 4, length: 1, type: 0b1, modifiers: 0b101),
            SemanticToken(line: 0, char: 5, length: 1, type: 0b100, modifiers: 0b1010),
            SemanticToken(line: 0, char: 7, length: 10, type: 0, modifiers: 0)
        ])
        let decoded = map.decode(tokens: tokens, using: mockProvider)
        XCTAssertEqual(decoded.count, 5, "Decoded count")

        XCTAssertEqual(decoded[0].range, NSRange(location: 0, length: 1), "Decoded range")
        XCTAssertEqual(decoded[1].range, NSRange(location: 1, length: 2), "Decoded range")
        XCTAssertEqual(decoded[2].range, NSRange(location: 4, length: 1), "Decoded range")
        XCTAssertEqual(decoded[3].range, NSRange(location: 5, length: 1), "Decoded range")
        XCTAssertEqual(decoded[4].range, NSRange(location: 7, length: 10), "Decoded range")

        XCTAssertEqual(decoded[0].capture, nil, "No Decoded Capture")
        XCTAssertEqual(decoded[1].capture, nil, "No Decoded Capture")
        XCTAssertEqual(decoded[2].capture, .include, "Decoded Capture")
        XCTAssertEqual(decoded[3].capture, .keyword, "Decoded Capture")
        XCTAssertEqual(decoded[4].capture, nil, "No Decoded Capture")

        XCTAssertEqual(decoded[0].modifiers, [.declaration, .definition], "Decoded Modifiers")
        XCTAssertEqual(decoded[1].modifiers, [.readonly, .defaultLibrary], "Decoded Modifiers")
        XCTAssertEqual(decoded[2].modifiers, [.declaration, .readonly], "Decoded Modifiers")
        XCTAssertEqual(decoded[3].modifiers, [.definition, .async], "Decoded Modifiers")
        XCTAssertEqual(decoded[4].modifiers, [], "Decoded Modifiers")
    }
}
