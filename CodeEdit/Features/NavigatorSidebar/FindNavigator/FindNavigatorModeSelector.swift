//
//  SearchModeSelector.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI

struct FindNavigatorModeSelector: View {
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @State
    private var selectedMode: [SearchModeModel] {
        didSet {
            // sync the variables, as selectedMode is an array
            // and cannot be synced directly with @ObservedObject
            state.selectedMode = selectedMode
        }
    }

    init(state: WorkspaceDocument.SearchState) {
        self.state = state
        selectedMode = state.selectedMode
    }

    private func getMenuList(_ index: Int) -> [SearchModeModel] {
        index == 0 ? SearchModeModel.SearchModes : selectedMode[index - 1].children
    }

    private func onSelectMenuItem(_ index: Int, searchMode: SearchModeModel) {
        var newSelectedMode: [SearchModeModel] = []

        switch index {
        case 0:
                newSelectedMode.append(searchMode)
                self.updateSelectedMode(searchMode, searchModel: &newSelectedMode)
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

    private func updateSelectedMode(_ searchMode: SearchModeModel, searchModel: inout [SearchModeModel]) {
        if let secondMode = searchMode.children.first {
            if let selectedSecondMode = selectedMode.second, searchMode.children.contains(selectedSecondMode) {
                searchModel.append(contentsOf: selectedMode.dropFirst())
            } else {
                searchModel.append(secondMode)
                if let thirdMode = secondMode.children.first, let selectedThirdMode = selectedMode.third {
                    if secondMode.children.contains(selectedThirdMode) {
                        searchModel.append(selectedThirdMode)
                    } else {
                        searchModel.append(thirdMode)
                    }
                }
            }
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
        self.count > 1 ? self[1] : nil
    }

    var third: Element? {
        self.count > 2 ? self[2] : nil
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
        FindNavigatorModeSelector(state: WorkspaceDocument.SearchState(WorkspaceDocument()))
    }
}
