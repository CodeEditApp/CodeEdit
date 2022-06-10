//
//  SearchModeModel.swift
//  CodeEditModules/Search
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

// TODO: DOCS (Ziyuan Zhao)
// swiftlint:disable missing_docs
public struct SearchModeModel {
    public let title: String
    public let children: [SearchModeModel]
    public let needSelectionHightlight: Bool

    public static let Containing = SearchModeModel(title: "Containing", children: [], needSelectionHightlight: false)
    public static let MatchingWord = SearchModeModel(title: "Matching Word",
                                                     children: [],
                                                     needSelectionHightlight: true)
    public static let StartingWith = SearchModeModel(title: "Starting With",
                                                     children: [],
                                                     needSelectionHightlight: true)
    public static let EndingWith = SearchModeModel(title: "Ending With", children: [], needSelectionHightlight: true)

    public static let Text = SearchModeModel(title: "Text",
                                 children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                 needSelectionHightlight: false)
    public static let References = SearchModeModel(title: "References",
                                       children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                       needSelectionHightlight: true)
    public static let Definitions = SearchModeModel(title: "Definitions",
                                        children: [.Containing, .MatchingWord, .StartingWith, .EndingWith],
                                        needSelectionHightlight: true)
    public static let RegularExpression = SearchModeModel(title: "Regular Expression",
                                                   children: [],
                                                   needSelectionHightlight: true)
    public static let CallHierarchy = SearchModeModel(title: "Call Hierarchy",
                                                      children: [],
                                                      needSelectionHightlight: true)

    public static let Find = SearchModeModel(title: "Find",
                                 children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy],
                                 needSelectionHightlight: false)
    public static let Replace = SearchModeModel(title: "Replace",
                                    children: [.Text, .RegularExpression],
                                    needSelectionHightlight: true)

    public static let TextMatchingModes: [SearchModeModel] = [.Containing, .MatchingWord, .StartingWith, .EndingWith]
    public static let FindModes: [SearchModeModel] = [.Text,
                                                      .References,
                                                      .Definitions,
                                                      .RegularExpression,
                                                      .CallHierarchy]
    public static let ReplaceModes: [SearchModeModel] = [.Text, .RegularExpression]
    public static let SearchModes: [SearchModeModel] = [.Find, .Replace]

    public static func getAllModes(_ index: Int, currentSelected: [SearchModeModel]) -> [SearchModeModel] {
        switch index {
        case 0:
            return SearchModes
        case 1:
            if let searchMode = currentSelected.first {
                if searchMode == SearchModeModel.Find {
                    return SearchModes
                } else if searchMode == searchMode {
                    return ReplaceModes
                }
            } else {
                return []
            }
        case 2:
            return TextMatchingModes
        default:
            return []
        }
        return []
    }
}

extension SearchModeModel: Equatable {
    public static func == (lhs: SearchModeModel, rhs: SearchModeModel) -> Bool {
        lhs.title == rhs.title
            && lhs.children == rhs.children
            && lhs.needSelectionHightlight == rhs.needSelectionHightlight
    }
}
