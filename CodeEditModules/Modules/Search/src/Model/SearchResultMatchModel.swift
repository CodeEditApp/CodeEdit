//
//  SearchResultLineMatchModel.swift
//  CodeEditModules/Search
//
//  Created by Khan Winter on 7/6/22.
//

import Foundation
import WorkspaceClient

/// A struct for holding information about a search match.
public class SearchResultMatchModel: Hashable, Identifiable {
    public init(lineNumber: Int? = nil,
                file: WorkspaceClient.FileItem,
                lineContent: String? = nil,
                keywordRange: Range<String.Index>? = nil) {
        self.id = UUID()
        self.file = file
        self.lineNumber = lineNumber
        self.lineContent = lineContent
        self.keywordRange = keywordRange
    }

    public var id: UUID
    public var file: WorkspaceClient.FileItem
    public var lineNumber: Int?
    public var lineContent: String?
    public var keywordRange: Range<String.Index>?

    public var hasKeywordInfo: Bool {
        lineNumber != nil && lineContent != nil && keywordRange != nil
    }

    public static func == (lhs: SearchResultMatchModel, rhs: SearchResultMatchModel) -> Bool {
        return lhs.id == rhs.id
        && lhs.file == rhs.file
        && lhs.lineNumber == rhs.lineNumber
        && lhs.lineContent == rhs.lineContent
        && lhs.keywordRange == rhs.keywordRange
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(file)
        hasher.combine(lineNumber)
        hasher.combine(lineContent)
        hasher.combine(keywordRange)
    }
}
