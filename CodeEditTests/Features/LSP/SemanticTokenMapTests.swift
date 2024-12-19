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

    func testOptionA() {
        let map = SemanticTokenMap(semanticCapability: .optionA(SemanticTokensOptions(legend: testLegend)))

        // Test decode modifiers
        let modifierRaw = UInt32(0b1101)
        let decodedModifiers = map.decodeModifier(modifierRaw)
        XCTAssertEqual([.declaration, .readonly, .async], decodedModifiers)

        // Test decode tokens
        let tokens = SemanticTokens(tokens: [
            SemanticToken(line: 0, char: 0, length: 1, type: 0b11),
            SemanticToken(line: 0, char: 0, length: 1, type: 0b11)
        ])
    }

    func testOptionB() {

    }
}
