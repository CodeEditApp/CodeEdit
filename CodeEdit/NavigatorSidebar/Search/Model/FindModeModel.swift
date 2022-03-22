//
//  SearchModeModel.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation

struct SearchModeModel {
    let title: String
    let children: [SearchModeModel]
    let needSelectionHightlight: Bool

    static let Containing = SearchModeModel(title: "Containing", children: [], needSelectionHightlight: false)
    static let MatchingWord = SearchModeModel(title: "Matching Word", children: [], needSelectionHightlight: true)
    static let StartingWith = SearchModeModel(title: "Starting With", children: [], needSelectionHightlight: true)
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
    static let CallHierarchy = SearchModeModel(title: "Call Hierarchy", children: [], needSelectionHightlight: true)

    static let Find = SearchModeModel(title: "Find",
                                 children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy],
                                 needSelectionHightlight: false)
    static let Replace = SearchModeModel(title: "Replace",
                                    children: [.Text, .RegularExpression],
                                    needSelectionHightlight: true)

    static let TextMatchingModes: [SearchModeModel] = [.Containing, .MatchingWord, .StartingWith, .EndingWith]
    static let FindModes: [SearchModeModel] = [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy]
    static let ReplaceModes: [SearchModeModel] = [.Text, .RegularExpression]
    static let SearchModes: [SearchModeModel] = [.Find, .Replace]

    static func getAllModes(_ index: Int, currentSelected: [SearchModeModel]) -> [SearchModeModel] {
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
    static func == (lhs: SearchModeModel, rhs: SearchModeModel) -> Bool {
        return lhs.title == rhs.title
            && lhs.children == rhs.children
            && lhs.needSelectionHightlight == rhs.needSelectionHightlight
    }
}
