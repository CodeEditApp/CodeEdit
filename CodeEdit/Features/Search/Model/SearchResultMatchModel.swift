//
//  SearchResultLineMatchModel.swift
//  CodeEditModules/Search
//
//  Created by Khan Winter on 7/6/22.
//

import Foundation
import Cocoa

/// A struct for holding information about a search match.
class SearchResultMatchModel: Hashable, Identifiable {
    init(lineNumber: Int,
         file: WorkspaceClient.FileItem,
         lineContent: String,
         keywordRange: Range<String.Index>
    ) {
        self.id = UUID()
        self.file = file
        self.lineNumber = lineNumber
        self.lineContent = lineContent
        self.keywordRange = keywordRange
    }

    var id: UUID
    var file: WorkspaceClient.FileItem
    var lineNumber: Int
    var lineContent: String
    var keywordRange: Range<String.Index>

    var hasKeywordInfo: Bool {
        lineNumber >= 0 && !lineContent.isEmpty && !keywordRange.isEmpty
    }

    static func == (lhs: SearchResultMatchModel, rhs: SearchResultMatchModel) -> Bool {
        return lhs.id == rhs.id
        && lhs.file == rhs.file
        && lhs.lineNumber == rhs.lineNumber
        && lhs.lineContent == rhs.lineContent
        && lhs.keywordRange == rhs.keywordRange
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(file)
        hasher.combine(lineNumber)
        hasher.combine(lineContent)
        hasher.combine(keywordRange)
    }

    /// Returns a formatted `NSAttributedString` with the search result bolded.
    /// Will only return 60 characters before and after the matched result.
    /// - Returns: The formatted `NSAttributedString`
    func attributedLabel() -> NSAttributedString {

        // By default `NSTextView` will ignore any paragraph wrapping set to the label when it's
        // using an `NSAttributedString` so we need to set the wrap mode here.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13,
                                     weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: paragraphStyle
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13,
                                     weight: .bold),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]

        // Set up the search result string with the matched search in bold.
        // We also limit the result to 60 characters before and after the
        // match to reduce *massive* results in the search result list, and for
        // cases where a file may be formatted in one line (eg: a minimized JS file).
        let lowerIndex = lineContent.safeOffset(keywordRange.lowerBound, offsetBy: -60)
        let upperIndex = lineContent.safeOffset(keywordRange.upperBound, offsetBy: 60)
        let prefix = String(lineContent[lowerIndex..<keywordRange.lowerBound])
        let searchMatch = String(lineContent[keywordRange.lowerBound..<keywordRange.upperBound])
        let postfix = String(lineContent[keywordRange.upperBound..<upperIndex])

        let attributedString = NSMutableAttributedString(
            string: prefix,
            attributes: normalAttributes)
        attributedString.append(NSAttributedString(
            string: searchMatch,
            attributes: boldAttributes))
        attributedString.append(NSAttributedString(
            string: postfix,
            attributes: normalAttributes))

        return attributedString
    }
}
