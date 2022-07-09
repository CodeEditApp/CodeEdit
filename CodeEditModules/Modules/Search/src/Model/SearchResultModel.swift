//
//  SearchResultModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation
import WorkspaceClient

/// A struct for holding information about a file and any matches it may have for a search query.
public struct SearchResultModel: Hashable {
    public var file: WorkspaceClient.FileItem
    public var lineMatches: [SearchResultMatchModel]

    public init(
        file: WorkspaceClient.FileItem,
        lineMatches: [SearchResultMatchModel] = []
    ) {
        self.file = file
        self.lineMatches = lineMatches
    }
}
