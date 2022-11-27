//
//  SearchModeModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

// TODO: DOCS (Ziyuan Zhao)
struct SearchModeModel {
    let title: String
    let children: [SearchModeModel]
    let needSelectionHightlight: Bool

    static let Containing = SearchModeModel(title: "Containing", children: [], needSelectionHightlight: false)
    static let MatchingWord = SearchModeModel(title: "Matching Word",
                                                     children: [],
                                                     needSelectionHightlight: true)
    static let StartingWith = SearchModeModel(title: "Starting With",
                                                     children: [],
                                                     needSelectionHightlight: true)
    static let EndingWith = SearchModeModel(title: "Ending With", children: [], needSelectionHightlight: true)

    static let Text = SearchModeModel(title: "Text",
                                 children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                 needSelectionHightlight: false)
    static let References = SearchModeModel(title: "References",
                                       children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                       needSelectionHightlight: true)
    static let Definitions = SearchModeModel(title: "Definitions",
                                        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                        needSelectionHightlight: true)
    static let RegularExpression = SearchModeModel(title: "Regular Expression",
                                                   children: [],
                                                   needSelectionHightlight: true)
    static let CallHierarchy = SearchModeModel(title: "Call Hierarchy",
                                                      children: [],
                                                      needSelectionHightlight: true)

    static let Find = SearchModeModel(title: "Find",
                                 children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy],
                                 needSelectionHightlight: false)
    static let Replace = SearchModeModel(title: "Replace",
                                    children: [.Text, .RegularExpression],
                                    needSelectionHightlight: true)

    static let TextMatchingModes: [SearchModeModel] = [.Containing, .MatchingWord, .StartingWith, .EndingWith]
    static let FindModes: [SearchModeModel] = [.Text,
                                                      .References,
                                                      .Definitions,
                                                      .RegularExpression,
                                                      .CallHierarchy]
    static let ReplaceModes: [SearchModeModel] = [.Text, .RegularExpression]
    static let SearchModes: [SearchModeModel] = [.Find, .Replace]
}

extension SearchModeModel: Equatable {
    static func == (lhs: SearchModeModel, rhs: SearchModeModel) -> Bool {
        lhs.title == rhs.title
            && lhs.children == rhs.children
            && lhs.needSelectionHightlight == rhs.needSelectionHightlight
    }
}
