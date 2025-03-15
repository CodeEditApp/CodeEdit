//
//  SemanticTokenStorageTests.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import Foundation
import Testing
import CodeEditSourceEditor
import LanguageServerProtocol
@testable import CodeEdit

// For easier comparison while setting semantic tokens
extension SemanticToken: @retroactive Equatable {
    public static func == (lhs: SemanticToken, rhs: SemanticToken) -> Bool {
        lhs.type == rhs.type
        && lhs.modifiers == rhs.modifiers
        && lhs.line == rhs.line
        && lhs.char == rhs.char
        && lhs.length == rhs.length
    }
}

@Suite
struct SemanticTokenStorageTests {
    let storage = SemanticTokenStorage()

    let semanticTokens = [
        SemanticToken(line: 0, char: 0, length: 10, type: 0, modifiers: 0),
        SemanticToken(line: 1, char: 2, length: 5, type: 2, modifiers: 3),
        SemanticToken(line: 3, char: 8, length: 10, type: 1, modifiers: 0)
    ]

    @Test
    func initialState() async throws {
        #expect(storage.state == nil)
        #expect(storage.hasTokens == false)
        #expect(storage.lastResultId == nil)
    }

    @Test
    func setData() async throws {
        storage.setData(
            SemanticTokens(
                resultId: "1234",
                tokens: semanticTokens
            )
        )

        let state = try #require(storage.state)
        #expect(state.tokens == semanticTokens)
        #expect(state.resultId == "1234")

        #expect(storage.lastResultId == "1234")
        #expect(storage.hasTokens == true)
    }

    @Suite("ApplyDeltas")
    struct TokensDeltasTests {
        let storage = SemanticTokenStorage()

        let semanticTokens = [
            SemanticToken(line: 0, char: 0, length: 10, type: 0, modifiers: 0),
            SemanticToken(line: 1, char: 2, length: 5, type: 2, modifiers: 3),
            SemanticToken(line: 3, char: 8, length: 10, type: 1, modifiers: 0)
        ]

        @Test(
            arguments: [
                #"{ "resultId": "1", "edits": [{"start": 0, "deleteCount": 0, "data": [0, 2, 3, 0, 1] }] }"#
            ]
        )
        func applyDeltas(deltasJSON: String) async throws {
            // This is unfortunate, but there's no public initializer for these structs.
            // So we have to decode them from JSON strings
            let decoder = JSONDecoder()
            let deltas = try decoder.decode(SemanticTokensDelta.self, from: Data(deltasJSON.utf8))

            
        }

        @Test
        func invalidatedRanges() {

        }
    }
}
