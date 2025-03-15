//
//  SemanticTokenStorage.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import Foundation
import LanguageServerProtocol
import CodeEditSourceEditor

/// This class provides storage for semantic token data.
///
/// The LSP spec requires that clients keep the original compressed data to apply delta edits. Delta updates may
/// appear as a delta to a single number in the compressed array. This class maintains the current state of compressed
/// tokens and their decoded counterparts. It supports applying delta updates from the language server.
///
/// See ``SemanticTokenHighlightProvider`` for it's connection to the editor view.
final class SemanticTokenStorage: GenericSemanticTokenStorage {
    /// Represents compressed semantic token data received from a language server.
    struct CurrentState {
        let resultId: String?
        let tokenData: [UInt32]
        let tokens: [SemanticToken]
    }

    /// The last received result identifier.
    var lastResultId: String? {
        state?.resultId
    }

    /// Indicates if the storage object has received any data.
    /// Once `setData` has been called, this returns `true`.
    /// Other operations will fail without any data in the storage object.
    var hasReceivedData: Bool {
        state != nil
    }

    var state: CurrentState?

    /// Create an empty storage object.
    init() {
        state = nil
    }

    // MARK: - Storage Conformance

    /// Finds all tokens in the given range.
    /// - Parameter range: The range to query.
    /// - Returns: All tokens found in the range.
    func getTokensFor(range: LSPRange) -> [SemanticToken] {
        guard let state = state, !state.tokens.isEmpty else {
            return []
        }
        var tokens: [SemanticToken] = []

        // Perform a binary search
        guard var idx = findLowerBound(in: range, data: state.tokens[...]) else {
            return []
        }

        while idx < state.tokens.count && state.tokens[idx].startPosition < range.end {
            tokens.append(state.tokens[idx])
            idx += 1
        }

        return tokens
    }

    /// Clear the current state and set a new one.
    /// - Parameter data: The semantic tokens to set as the current state.
    func setData(_ data: borrowing SemanticTokens) {
        state = CurrentState(resultId: data.resultId, tokenData: data.data, tokens: data.decode())
    }

    /// Apply a delta object from a language server and returns all token ranges that may need re-drawing.
    ///
    /// To calculate invalidated ranges:
    /// - Grabs all semantic tokens that *will* be updated and invalidates their ranges
    /// - Loops over all inserted tokens and invalidates their ranges
    /// This may result in duplicated ranges. It's up to the caller to de-duplicate if necessary. See
    /// ``SemanticTokenStorage/invalidatedRanges(startIdx:length:data:)``.
    ///
    /// - Parameter deltas: The deltas to apply.
    /// - Returns: Ranges invalidated by the applied deltas.
    func applyDelta(_ deltas: SemanticTokensDelta) -> [SemanticTokenRange] {
        assert(state != nil, "State should be set before applying any deltas.")
        guard var tokenData = state?.tokenData else { return [] }
        var invalidatedSet: [SemanticTokenRange] = []

        // Apply in reverse order (end to start)
        for edit in deltas.edits.sorted(by: { $0.start > $1.start }) {
            invalidatedSet.append(
                contentsOf: invalidatedRanges(startIdx: edit.start, length: edit.deleteCount, data: tokenData[...])
            )

            // Apply to our copy of the tokens array
            if edit.deleteCount > 0 {
                tokenData.replaceSubrange(Int(edit.start)..<Int(edit.start + edit.deleteCount), with: edit.data ?? [])
            } else {
                tokenData.insert(contentsOf: edit.data ?? [], at: Int(edit.start))
            }

            if edit.data != nil {
                invalidatedSet.append(
                    contentsOf: invalidatedRanges(
                        startIdx: edit.start,
                        length: UInt(edit.data?.count ?? 0),
                        data: tokenData[...]
                    )
                )
            }
        }

        // Re-decode the updated token data and set the updated state
        let decodedTokens = SemanticTokens(data: tokenData).decode()
        state = CurrentState(resultId: deltas.resultId, tokenData: tokenData, tokens: decodedTokens)
        return invalidatedSet
    }

    // MARK: - Invalidated Indices

    /// Calculate what document ranges are invalidated due to changes in the compressed token data.
    ///
    /// This overestimates invalidated ranges by assuming all tokens touched by a change are invalid. All this does is
    /// find what tokens are being updated by a delta and return them.
    ///
    /// - Parameters:
    ///   - startIdx: The start index of the compressed token data an edits start at.
    ///   - length: The length of any edits.
    ///   - data: A reference to the compressed token data.
    /// - Returns: All token ranges included in the range of the edit.
    func invalidatedRanges(startIdx: UInt, length: UInt, data: ArraySlice<UInt32>) -> [SemanticTokenRange] {
        var ranges: [SemanticTokenRange] = []
        var idx = startIdx - (startIdx % 5)
        while idx < startIdx + length {
            ranges.append(
                SemanticTokenRange(
                    line: data[Int(idx)],
                    char: data[Int(idx + 1)],
                    length: data[Int(idx + 2)]
                )
            )
            idx += 5
        }
        return ranges
    }

    // MARK: - Binary Search

    /// Finds the lowest index of a `SemanticToken` that is entirely within the specified range.
    /// - Complexity: Runs an **O(log n)** binary search on the data array.
    /// - Parameters:
    ///   - range: The range to search in, *not* inclusive.
    ///   - data: The tokens to search. Takes an array slice to avoid unnecessary copying. This must be ordered by
    ///           `startPosition`.
    /// - Returns: The index in the data array of the lowest data element that lies within the given range, or `nil`
    ///            if none are found.
    func findLowerBound(in range: LSPRange, data: ArraySlice<SemanticToken>) -> Int? {
        var low = 0
        var high = data.count

        // Find the first token with startPosition >= range.start.
        while low < high {
            let mid = low + (high - low) / 2
            if data[mid].startPosition < range.start {
                low = mid + 1
            } else {
                high = mid
            }
        }

        // Return the item at `low` if it's valid.
        if low < data.count && data[low].startPosition >= range.start && data[low].endPosition < range.end {
            return low
        }

        return nil
    }
}
