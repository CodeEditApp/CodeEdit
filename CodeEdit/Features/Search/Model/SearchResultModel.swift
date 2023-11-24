//
//  SearchResultModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

/// A struct for holding information about a file and any matches it may have for a search query.
class SearchResultModel: Hashable {

    var file: CEWorkspaceFile
    // The score represents how well the file matches the search query.
    // The heigher the score is, the better the file matches the search query.
    // The score is assign by Search Kit.
    var score: Float
    var lineMatches: [SearchResultMatchModel]

    init(
        file: CEWorkspaceFile,
        score: Float,
        lineMatches: [SearchResultMatchModel] = []
    ) {
        self.file = file
        self.score = score
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
