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
        #expect(storage.hasReceivedData == false)
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
        #expect(storage.hasReceivedData == true)
    }

    @Test
    func overwriteDataRepeatedly() async throws {
        let dataToApply: [(String?, [SemanticToken])] = [
            (nil, semanticTokens),
            ("1", []),
            ("2", semanticTokens.dropLast()),
            ("3", semanticTokens)
        ]
        for (resultId, tokens) in dataToApply {
            storage.setData(SemanticTokens(resultId: resultId, tokens: tokens))
            let state = try #require(storage.state)
            #expect(state.tokens == tokens)
            #expect(state.resultId == resultId)
            #expect(storage.lastResultId == resultId)
            #expect(storage.hasReceivedData == true)
        }
    }

    @Suite("ApplyDeltas")
    struct TokensDeltasTests {
        struct DeltaEdit {
            let start: Int
            let deleteCount: Int
            let data: [Int]

            func makeString() -> String {
                let dataString = data.map { String($0) }.joined(separator: ",")
                return "{\"start\": \(start), \"deleteCount\": \(deleteCount), \"data\": [\(dataString)] }"
            }
        }

        func makeDelta(resultId: String, edits: [DeltaEdit]) throws -> SemanticTokensDelta {
            // This is unfortunate, but there's no public initializer for these structs.
            // So we have to decode them from JSON strings
            let editsString = edits.map { $0.makeString() }.joined(separator: ",")
            let deltasJSON = "{ \"resultId\": \"\(resultId)\", \"edits\": [\(editsString)] }"
            let decoder = JSONDecoder()
            let deltas = try decoder.decode(SemanticTokensDelta.self, from: Data(deltasJSON.utf8))
            return deltas
        }

        let storage: SemanticTokenStorage

        let semanticTokens = [
            SemanticToken(line: 0, char: 0, length: 10, type: 0, modifiers: 0),
            SemanticToken(line: 1, char: 2, length: 5, type: 2, modifiers: 3),
            SemanticToken(line: 3, char: 8, length: 10, type: 1, modifiers: 0)
        ]

        init() {
            storage = SemanticTokenStorage()
            storage.setData(SemanticTokens(tokens: semanticTokens))
            #expect(storage.state?.tokens == semanticTokens)
        }

        @Test
        func applyEmptyDeltasNoChange() throws {
            let deltas = try makeDelta(resultId: "1", edits: [])

            _ = storage.applyDelta(deltas)

            let state = try #require(storage.state)
            #expect(state.tokens.count == 3)
            #expect(state.resultId == "1")
            #expect(state.tokens == semanticTokens)
        }

        @Test
        func applyInsertDeltas() throws {
            let deltas = try makeDelta(resultId: "1", edits: [.init(start: 0, deleteCount: 0, data: [0, 2, 3, 0, 1])])

            _ = storage.applyDelta(deltas)

            let state = try #require(storage.state)
            #expect(state.tokens.count == 4)
            #expect(storage.lastResultId == "1")

            // Should have inserted one at the beginning
            #expect(state.tokens[0].line == 0)
            #expect(state.tokens[0].char == 2)
            #expect(state.tokens[0].length == 3)
            #expect(state.tokens[0].modifiers == 1)

            // We inserted a delta into the space before this one (at char 2) so this one starts at the same spot
            #expect(state.tokens[1] == SemanticToken(line: 0, char: 2, length: 10, type: 0, modifiers: 0))
            #expect(state.tokens[2] == semanticTokens[1])
            #expect(state.tokens[3] == semanticTokens[2])
        }

        @Test
        func applyDeleteOneDeltas() throws {
            // Delete the second token (semanticTokens[1]) from the initial state.
            // Each token is represented by 5 numbers, so token[1] starts at raw data index 5.
            let deltas = try makeDelta(resultId: "2", edits: [.init(start: 5, deleteCount: 5, data: [])])
            _ = storage.applyDelta(deltas)

            let state = try #require(storage.state)
            #expect(state.tokens.count == 2)
            #expect(state.resultId == "2")
            // The remaining tokens should be the first and third tokens, except we deleted one line between them
            // so the third token's line is less one
            #expect(state.tokens[0] == semanticTokens[0])
            #expect(state.tokens[1] == SemanticToken(line: 2, char: 8, length: 10, type: 1, modifiers: 0))
        }

        @Test
        func applyDeleteManyDeltas() throws {
            // Delete the first two tokens from the initial state.
            // Token[0] and token[1] together use 10 integers.
            let deltas = try makeDelta(resultId: "3", edits: [.init(start: 0, deleteCount: 10, data: [])])
            _ = storage.applyDelta(deltas)

            let state = try #require(storage.state)
            #expect(state.tokens.count == 1)
            #expect(state.resultId == "3")
            // The only remaining token should be the original third token.
            #expect(state.tokens[0] == SemanticToken(line: 2, char: 8, length: 10, type: 1, modifiers: 0))
        }

        @Test
        func applyInsertAndDeleteDeltas() throws {
            // Combined test: insert a token at the beginning and delete the last token.
            // Edit 1: Insert a new token at the beginning.
            let insertion = DeltaEdit(start: 0, deleteCount: 0, data: [0, 2, 3, 0, 1])
            // Edit 2: Delete the token that starts at raw data index 10 (the third token in the original state).
            let deletion = DeltaEdit(start: 10, deleteCount: 5, data: [])
            let deltas = try makeDelta(resultId: "4", edits: [insertion, deletion])
            _ = storage.applyDelta(deltas)

            let state = try #require(storage.state)
            #expect(state.tokens.count == 3)
            #expect(storage.lastResultId == "4")
            // The new inserted token becomes the first token.
            #expect(state.tokens[0] == SemanticToken(line: 0, char: 2, length: 3, type: 0, modifiers: 1))
            // The original first token is shifted (its character offset increased by 2).
            #expect(state.tokens[1] == SemanticToken(line: 0, char: 2, length: 10, type: 0, modifiers: 0))
            // The second token from the original state remains unchanged.
            #expect(state.tokens[2] == semanticTokens[1])
        }
    }
}
