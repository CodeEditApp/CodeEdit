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

    @State private var includesText: String = ""
    @State private var excludesText: String = ""
    @State private var scoped: Bool = false
    @State private var caseSensitive: Bool = false
    @State private var preserveCase: Bool = false
    @State private var scopedToOpenEditors: Bool = false
    @State private var excludeSettings: Bool = true
    @FocusState private var isSearchFieldFocused: Bool

    init(state: WorkspaceDocument.SearchState) {
        self.state = state
        selectedMode = state.selectedMode
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
                        FindModePicker(
                            modes: getMenuList(index),
                            selection: Binding(
                                get: {
                                    selectedMode[index]
                                },
                                set: { searchMode in
                                    onSelectMenuItem(index, searchMode: searchMode)
                                }
                            ),
                            onSelect: { searchMode in
                                onSelectMenuItem(index, searchMode: searchMode)
                            },
                            isLastItem: index == selectedMode.count-1
                        )
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
            .padding(.top, -5)
            .padding(.bottom, -8)
            PaneTextField(
                state.selectedMode[1].title,
                text: $state.searchQuery,
                axis: .vertical,
                leadingAccessories: {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 12))
                        .frame(width: 16, height: 20)
                },
                trailingAccessories: {
                    Divider()
                    Toggle(
                        isOn: $caseSensitive,
                        label: {
                        Image(systemName: "textformat")
                            .foregroundStyle(caseSensitive ? Color(.controlAccentColor) : Color(.secondaryLabelColor))
                        }
                    )
                    .help("Match Case")
                    .onChange(of: caseSensitive) { newValue in
                        state.caseSensitive = newValue
                    }
                },
                clearable: true,
                onClear: {
                    state.clearResults()
                },
                hasValue: caseSensitive
            )
            .focused($isSearchFieldFocused)
            .onSubmit {
                if !state.searchQuery.isEmpty {
                    Task {
                        await state.search(state.searchQuery)
                    }
                } else {
                    // If a user performs a search with an empty string, the search results will be cleared.
                    // This behavior aligns with Xcode's handling of empty search queries.
                    state.clearResults()
                }
            }
            if selectedMode[0] == SearchModeModel.Replace {
                PaneTextField(
                    "With",
                    text: $state.replaceText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "arrow.2.squarepath")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $preserveCase,
                            label: {
                                Text("AB")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(
                                        preserveCase ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Preserve Case")
                    },
                    clearable: true,
                    hasValue: preserveCase
                )
            }
            if scoped {
                PaneTextField(
                    "Only in folders",
                    text: $includesText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "folder.badge.plus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $scopedToOpenEditors,
                            label: {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(
                                        scopedToOpenEditors ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Search only in Open Editors")
                    },
                    clearable: true,
                    hasValue: scopedToOpenEditors
                )
                PaneTextField(
                    "Excluding folders",
                    text: $excludesText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "folder.badge.minus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $excludeSettings,
                            label: {
                                Image(systemName: "gearshape")
                                    .foregroundStyle(
                                        excludeSettings ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Use Exclude Settings and Ignore Files")
                    },
                    clearable: true,
                    hasValue: excludeSettings
                )
            }
            if selectedMode[0] == SearchModeModel.Replace {
                Button {
                    Task {
                        let startTime = Date()
                        try? await state.findAndReplace(query: state.searchQuery, replacingTerm: state.replaceText)
                        print(Date().timeIntervalSince(startTime))
                    }
                } label: {
                    Text("Replace All")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .onReceive(state.$shouldFocusSearchField) { shouldFocus in
            if shouldFocus {
                isSearchFieldFocused = true
                state.shouldFocusSearchField = false
            }
        }
        .lineLimit(1...5)
    }
}

extension FindNavigatorForm {
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
}
