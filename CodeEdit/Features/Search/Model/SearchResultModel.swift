//
//  SearchResultModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

/// A struct for holding information about a file and any matches it may have for a search query.
class SearchResultModel: Hashable {
    var file: WorkspaceClient.FileItem
    var lineMatches: [SearchResultMatchModel]

    init(
        file: WorkspaceClient.FileItem,
        lineMatches: [SearchResultMatchModel] = []
    ) {
        self.file = file
        self.lineMatches = lineMatches
    }

    static func == (lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
        return lhs.file == rhs.file
        && lhs.lineMatches == rhs.lineMatches
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(lineMatches)
    }
}
