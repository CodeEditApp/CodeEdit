//
//  SearchModeSelector.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI
import Search

struct FindNavigatorModeSelector: View {
    @State
    var selectedMode: [SearchModeModel] = [
        .Find,
        .Text,
        .Containing
    ]

    private func getMenuList(_ index: Int) -> [SearchModeModel] {
        return index == 0 ? SearchModeModel.SearchModes : selectedMode[index - 1].children
    }

    // TODO: improve this function and remove swiftlint comment
    // swiftlint:disable:next cyclomatic_complexity
    private func onSelectMenuItem(_ index: Int, searchMode: SearchModeModel) {
        var newSelectedMode: [SearchModeModel] = []
        switch index {
        case 0:
            newSelectedMode.append(searchMode)
            if let secondMode = searchMode.children.first {
                if let selectedSecondMode = selectedMode.second, searchMode.children.contains(selectedSecondMode) {
                    newSelectedMode.append(contentsOf: selectedMode.dropFirst())
                } else {
                    newSelectedMode.append(secondMode)
                    if let thirdMode = secondMode.children.first, let selectedThirdMode = selectedMode.third {
                        if secondMode.children.contains(selectedThirdMode) {
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
            if let firstMode = selectedMode.first, let secondMode = selectedMode.second {
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
                    ForEach(getMenuList(index), id: \.title) { (searchMode: SearchModeModel) in
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
        FindNavigatorModeSelector()
    }
}
