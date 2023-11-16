//
//  SearchModeSelector.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI

struct FindNavigatorForm: View {
    @ObservedObject private var state: WorkspaceDocument.SearchState

    @State private var selectedMode: [SearchModeModel] {
        didSet {
            // sync the variables, as selectedMode is an array
            // and cannot be synced directly with @ObservedObject
            state.selectedMode = selectedMode
        }
    }

    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var includesText: String = ""
    @State private var excludesText: String = ""
    @State private var scoped: Bool = false
    @State private var caseSensitive: Bool = false
    @State private var preserveCase: Bool = false
    @State private var scopedToOpenEditors: Bool = false
    @State private var excludeSettings: Bool = true

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
                    if let selectedThirdMode = selectedMode.third, searchMode.children.contains(selectedThirdMode) {
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
            .foregroundStyle(.tertiary)
            .imageScale(.large)
    }

    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 0) {
                    ForEach(0..<selectedMode.count, id: \.self) { index in
                        if index > 0 {
                            chevron
                        }
                        Menu {
                            ForEach(getMenuList(index), id: \.title) { (searchMode: SearchModeModel) in
                                Button(searchMode.title) {
                                    onSelectMenuItem(index, searchMode: searchMode)
                                }
                            }
                        } label: {
                            Text(selectedMode[index].title)
                                .foregroundColor(
                                    selectedMode[index].needSelectionHighlight
                                    ? Color.accentColor
                                    : .primary
                                )
                                .font(.system(size: 11))
                        }
                        .searchModeMenu()
                    }
                    Spacer()
                }
                Spacer()
                Text("Scoped")
                    .controlSize(.small)
                    .foregroundStyle(Color(nsColor: scoped ? .controlAccentColor : .controlTextColor))
                    .onTapGesture {
                        scoped.toggle()
                    }
            }
            PaneTextField(
                state.selectedMode[1].title,
                text: $searchText,
                leadingAccessories: {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 12))
                        .frame(width: 16, height: 16)
                },
                trailingAccessories: {
                    Divider()
                    Button {
                        caseSensitive.toggle()
                    } label: {
                        Image(systemName: "textformat")
                            .foregroundStyle(caseSensitive ? Color(.controlAccentColor) : Color(.secondaryLabelColor))
                    }
                },
                clearable: true,
                onClear: {
                    state.search(nil)
                }
            )
            .onSubmit {
                state.search(searchText)
            }
            if selectedMode[0] == SearchModeModel.Replace {
                PaneTextField(
                    "With",
                    text: $replaceText,
                    leadingAccessories: {
                        Image(systemName: "arrow.2.squarepath")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 16)
                    },
                    trailingAccessories: {
                        Divider()
                        Button {
                            preserveCase.toggle()
                        } label: {
                            Text("AB")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(
                                    preserveCase
                                    ? Color(.controlAccentColor)
                                    : Color(.secondaryLabelColor)
                                )
                        }
                    },
                    clearable: true
                )
            }
            if scoped {
                PaneTextField(
                    "Only in folders",
                    text: $includesText,
                    leadingAccessories: {
                        Image(systemName: "plus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 16)
                    },
                    trailingAccessories: {
                        Divider()
                        Button {
                            scopedToOpenEditors.toggle()
                        } label: {
                            Image(systemName: "doc.plaintext")
                                .foregroundStyle(
                                    scopedToOpenEditors
                                    ? Color(.controlAccentColor)
                                    : Color(.secondaryLabelColor)
                                )
                        }
                    },
                    clearable: true
                )
                PaneTextField(
                    "Excluding folders",
                    text: $excludesText,
                    leadingAccessories: {
                        Image(systemName: "minus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 16)
                    },
                    trailingAccessories: {
                        Divider()
                        Button {
                            excludeSettings.toggle()
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(
                                    excludeSettings
                                    ? Color(.controlAccentColor)
                                    : Color(.secondaryLabelColor)
                                )
                        }
                    },
                    clearable: true
                )
            }
            if selectedMode[0] == SearchModeModel.Replace {
                Button {
                    // replace all
                } label: {
                    Text("Replace All")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
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
