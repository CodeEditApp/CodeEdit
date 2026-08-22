//
//  SearchResultModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation
import CodeEditCore

/// A struct for holding information about a file and any matches it may have for a search query.
public class SearchResultModel: Hashable {

    public var file: SearchResultFile
    // The score represents how well the file matches the search query.
    // The higher the score is, the better the file matches the search query.
    // The score is assign by Search Kit.
    public var score: Float
    public var lineMatches: [SearchResultMatchModel]

    public init(
        file: SearchResultFile,
        score: Float,
        lineMatches: [SearchResultMatchModel] = []
    ) {
        self.file = file
        self.score = score
        self.lineMatches = lineMatches
    }

    public static func == (lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
        return lhs.file == rhs.file
        && lhs.lineMatches == rhs.lineMatches
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(lineMatches)
    }

}
