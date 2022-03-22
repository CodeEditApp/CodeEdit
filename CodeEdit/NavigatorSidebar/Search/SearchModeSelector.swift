//
//  SearchModeSelector.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI

struct SearchMode {
    let title: String
    let children: [SearchMode]
    let needSelectionHightlight: Bool
    
    static let Containing = SearchMode(title: "Containing", children: [], needSelectionHightlight: false)
    static let MatchingWord = SearchMode(title: "Matching Word", children: [], needSelectionHightlight: true)
    static let StartingWith = SearchMode(title: "Starting With", children: [], needSelectionHightlight: true)
    static let EndingWith = SearchMode(title: "Ending With", children: [], needSelectionHightlight: true)

    static let Text = SearchMode(title: "Text", children: [.Containing, .MatchingWord, .StartingWith, .EndingWith], needSelectionHightlight: false)
    static let References = SearchMode(title: "References", children: [.Containing, .MatchingWord, .StartingWith, .EndingWith], needSelectionHightlight: true)
    static let Definitions = SearchMode(title: "Definitions", children: [.Containing, .MatchingWord, .StartingWith, .EndingWith], needSelectionHightlight: true)
    static let RegularExpression = SearchMode(title: "Regular Expression", children: [], needSelectionHightlight: true)
    static let CallHierarchy = SearchMode(title: "Call Hierarchy", children: [], needSelectionHightlight: true)
    
    static let Find = SearchMode(title: "Find", children: [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy], needSelectionHightlight: false)
    static let Replace = SearchMode(title: "Replace", children: [.Text, .RegularExpression], needSelectionHightlight: true)
    
    static let Search = SearchMode(title: "", children: [.Find, .Replace], needSelectionHightlight: false)
    
    static let TextMatchingModes: [SearchMode] = [.Containing, .MatchingWord, .StartingWith, .EndingWith]
    static let FindModes: [SearchMode] = [.Text, .References, .Definitions, .RegularExpression, .CallHierarchy]
    static let ReplaceModes: [SearchMode] = [.Text, .RegularExpression]
    static let SearchModes: [SearchMode] = [.Find, .Replace]
    
    static func getAllModes(_ index: Int, currentSelected: [SearchMode]) -> [SearchMode] {
        switch index {
        case 0:
            return SearchModes
        case 1:
            if let searchMode = currentSelected.first {
                if searchMode == SearchMode.Find {
                    return FindModes
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

extension SearchMode: Equatable {
    static func ==(lhs: SearchMode, rhs: SearchMode) -> Bool {
        return lhs.title == rhs.title && lhs.children == rhs.children && lhs.needSelectionHightlight == rhs.needSelectionHightlight
    }
}

struct SearchModeSelector: View {
    
    @State var selectedMode: [SearchMode] = [
        .Find,
        .Text,
        .Containing
    ]
    
    private func getMenuList(_ index: Int) -> [SearchMode] {
        return index == 0 ? SearchMode.SearchModes : selectedMode[index - 1].children
    }
    
    private func onSelectMenuItem(_ index: Int, searchMode: SearchMode) {
        var newSelectedMode: [SearchMode] = []
        switch index {
        case 0:
            newSelectedMode.append(searchMode)
            if let secondMode = searchMode.children.first {
                if let selectedSecondMode = selectedMode.second, searchMode.children.contains(selectedSecondMode) {
                    newSelectedMode.append(contentsOf: selectedMode.dropFirst())
                } else {
                    newSelectedMode.append(secondMode)
                    if let thirdMode = secondMode.children.first, let selectedThirdMode = selectedMode.third {
                        if (secondMode.children.contains(selectedThirdMode)) {
                            newSelectedMode.append(selectedThirdMode)
                        } else {
                            newSelectedMode.append(thirdMode)
                        }
                    }
                }
            }
            self.selectedMode = newSelectedMode
        case 1:
            if let firstMode = selectedMode.first {
                newSelectedMode.append(contentsOf: [firstMode, searchMode])
                if let thirdMode = searchMode.children.first {
                    if let selectedThirdMode = selectedMode.third, (searchMode.children.contains(selectedThirdMode)) {
                        newSelectedMode.append(selectedThirdMode)
                    } else {
                        newSelectedMode.append(thirdMode)
                    }
                }
            }
            self.selectedMode = newSelectedMode
        case 2:
            if let firstMode = selectedMode.first, let secondMode = selectedMode.second  {
                newSelectedMode.append(contentsOf: [firstMode, secondMode, searchMode])
            }
            self.selectedMode = newSelectedMode
        default:
            return
        }
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .foregroundStyle(.secondary)
            .imageScale(.large)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<selectedMode.count, id: \.self) { index in
                Menu {
                    ForEach(getMenuList(index), id: \.title) { searchMode in
                        Button(searchMode.title) {
                            onSelectMenuItem(index, searchMode: searchMode)
                        }
                    }
                } label: {
                    HStack(spacing: 2) {
                        if index > 0 {
                            chevron
                        }
                        Text(selectedMode[index].title)
                            .foregroundColor(selectedMode[index].needSelectionHightlight ? Color.accentColor : .primary)
                            .font(.system(size: 10))
                    }
                }
                .searchModeMenu()
            }
            Spacer()
        }
    }
}

extension Array {
    var second: Element? {
        return self.count > 1 ? self[1] : nil
    }
    
    var third: Element? {
        return self.count > 2 ? self[2] : nil
    }
}

extension View {
    func searchModeMenu() -> some View {
        menuStyle(.borderlessButton)
            .fixedSize()
            .menuIndicator(.hidden)
    }
}

struct SearchModeSelector_Previews: PreviewProvider {
    static var previews: some View {
        SearchModeSelector()
    }
}
