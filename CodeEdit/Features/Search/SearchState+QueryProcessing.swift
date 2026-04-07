//
//  SearchState+QueryProcessing.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 02.01.24.
//

import Foundation

extension SearchState {
    /// Creates a search term based on the given query and search mode.
    ///
    /// - Parameter query: The original user query string.
    ///
    /// - Returns: A modified search term according to the specified search mode.
    func getSearchTerm(_ query: String) -> String {
        let newQuery = stripSpecialCharacters(from: (caseSensitive ? query : query.lowercased()))
        guard let mode = selectedMode.third else {
            return newQuery
        }

        switch mode {
        case .Containing:
            return "*\(newQuery)*"
        case .StartingWith:
            return "\(newQuery)*"
        case .EndingWith:
            return "*\(newQuery)"
        default:
            return newQuery
        }
    }

    func stripSpecialCharacters(from string: String) -> String {
        let regex = try? NSRegularExpression(pattern: "[^a-zA-Z0-9]+", options: .caseInsensitive)
        return regex!.stringByReplacingMatches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count),
            withTemplate: "*"
        )
    }

    /// Generates a regular expression pattern based on the specified query and search mode.
    ///
    /// - Parameter query: The original user query string.
    ///
    /// - Returns: A string representing the regular expression pattern based on the selected search mode.
    ///
    /// - Note: This function is creating similar patterns to the
    /// ``Workspace/SearchState-swift.class/getSearchTerm(_:)`` function,
    /// Except its using the word boundary anchor(\b) instead of the asterisk(\*).
    /// This is needed to highlight the search results correctly.
    func getRegexPattern(_ query: String) -> String {
        let newQuery = NSRegularExpression.escapedPattern(for: query.trimmingCharacters(in: .whitespacesAndNewlines))

        guard let mode = selectedMode.third else {
            return newQuery
        }

        switch mode {
        case .Containing:
            return "\(newQuery)"
        case .StartingWith:
            return "\\b\(newQuery)"
        case .EndingWith:
            return "\(newQuery)\\b"
        case .MatchingWord:
            return "\\b\(newQuery)\\b"
        default:
            return newQuery
        }
    }
}
