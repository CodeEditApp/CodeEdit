//
//  SearchResultLineMatchModel.swift
//  CodeEditModules/Search
//
//  Created by Khan Winter on 7/6/22.
//

import Foundation
import WorkspaceClient

/// A struct for holding information about a search match.
public struct SearchResultMatchModel: Hashable, Identifiable {
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
}
