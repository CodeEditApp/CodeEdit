//
//  SearchModeModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

// TODO: DOCS (Ziyuan Zhao)
public struct SearchModeModel: Hashable, Sendable {
    public let title: String
    public let children: [SearchModeModel]
    public let needSelectionHighlight: Bool

    public init(title: String, children: [SearchModeModel], needSelectionHighlight: Bool) {
        self.title = title
        self.children = children
        self.needSelectionHighlight = needSelectionHighlight
    }

    public static let Containing = SearchModeModel(title: "Containing", children: [], needSelectionHighlight: false)
    public static let MatchingWord = SearchModeModel(
        title: "Matching Word",
        children: [],
        needSelectionHighlight: true
    )
    public static let StartingWith = SearchModeModel(
        title: "Starting With",
        children: [],
        needSelectionHighlight: true
    )
    public static let EndingWith = SearchModeModel(
        title: "Ending With",
        children: [],
        needSelectionHighlight: true
    )

    public static let Text = SearchModeModel(
        title: "Text",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHighlight: false
    )
    public static let References = SearchModeModel(
        title: "References",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHighlight: true
    )
    public static let Definitions = SearchModeModel(
        title: "Definitions",
        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
        needSelectionHighlight: true
    )
    public static let RegularExpression = SearchModeModel(
        title: "Regular Expression",
        children: [],
        needSelectionHighlight: true
    )
    public static let CallHierarchy = SearchModeModel(
        title: "Call Hierarchy",
        children: [],
        needSelectionHighlight: true
    )

    public static let Find = SearchModeModel(
        title: "Find",
        children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy],
        needSelectionHighlight: false
    )
    public static let Replace = SearchModeModel(
        title: "Replace",
        children: [.Text, .RegularExpression],
        needSelectionHighlight: true
    )

    public static let TextMatchingModes: [SearchModeModel] = [
        .Containing, .MatchingWord, .StartingWith, .EndingWith
    ]
    public static let FindModes: [SearchModeModel] = [
        .Text,
        .References,
        .Definitions,
        .RegularExpression,
        .CallHierarchy
    ]
    public static let ReplaceModes: [SearchModeModel] = [.Text, .RegularExpression]
    public static let SearchModes: [SearchModeModel] = [.Find, .Replace]
}

extension SearchModeModel: Equatable {
    public static func == (lhs: SearchModeModel, rhs: SearchModeModel) -> Bool {
        lhs.title == rhs.title
            && lhs.children == rhs.children
            && lhs.needSelectionHighlight == rhs.needSelectionHighlight
    }
}
