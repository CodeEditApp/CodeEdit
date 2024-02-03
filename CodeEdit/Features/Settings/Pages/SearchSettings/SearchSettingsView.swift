//
//  SearchSettingsView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchSettingsView: View {
    var body: some View {
        SettingsForm {
            Section {
                ExcludedGlobPatternList()
            } header: {
                Text("Exclude")
                Text(
                    "Add glob patterns to exclude matching files and folders from searches and open quickly. " +
                    "This will inherit glob patterns from the Exclude from Project setting."
                )
            }
        }
    }
}

struct ExcludedGlobPatternList: View {
    @ObservedObject private var searchSettingsModel: SearchSettingsModel = .shared

    @FocusState private var focusedField: String?

    @State private var selection: GlobPattern?

    var body: some View {
        List(selection: $selection) {
            ForEach(
                Array(searchSettingsModel.ignoreGlobPatterns.enumerated()),
                id: \.element
            ) { index, ignorePattern in
                IgnorePatternListItem(
                    pattern: $searchSettingsModel.ignoreGlobPatterns[index],
                    selectedPattern: $selection,
                    addPattern: addPattern,
                    removePattern: removePattern,
                    focusedField: $focusedField,
                    isLast: searchSettingsModel.ignoreGlobPatterns.count == index+1
                )
                .onAppear {
                    if ignorePattern.value.isEmpty {
                        focusedField = ignorePattern.id.uuidString
                    }
                }
            }
            .onMove { fromOffsets, toOffset in
                searchSettingsModel.ignoreGlobPatterns.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        .frame(minHeight: 96)
        .contextMenu(
            forSelectionType: GlobPattern.self,
            menu: { selection in
                if let pattern = selection.first {
                    Button("Edit") {
                        focusedField = pattern.id.uuidString
                    }
                    Button("Add") {
                        addPattern()
                    }
                    Divider()
                    Button("Remove") {
                        if !searchSettingsModel.ignoreGlobPatterns.isEmpty {
                            removePattern(pattern)
                        }
                    }
                }
            },
            primaryAction: { selection in
                if let pattern = selection.first {
                    focusedField = pattern.id.uuidString
                }
            }
        )
        .overlay {
            if searchSettingsModel.ignoreGlobPatterns.isEmpty {
                Text("No excluded glob patterns")
                    .foregroundStyle(Color(.secondaryLabelColor))
            }
        }
        .actionBar {
            Button {
                addPattern()
            } label: {
                Image(systemName: "plus")
            }
            Divider()
            Button {
                if let pattern = selection {
                    removePattern(pattern)
                }
            } label: {
                Image(systemName: "minus")
            }
            .disabled(selection == nil)
        }
        .onDeleteCommand {
            removePattern(selection)
        }
    }

    func addPattern() {
        searchSettingsModel.ignoreGlobPatterns.append(GlobPattern(value: ""))
    }

    func removePattern(_ pattern: GlobPattern?) {
        let selectedIndex = searchSettingsModel.ignoreGlobPatterns.firstIndex {
            $0 == selection
        }

        let removeIndex = searchSettingsModel.ignoreGlobPatterns.firstIndex {
            $0 == selection
        }

        searchSettingsModel.ignoreGlobPatterns.removeAll {
            pattern == $0
        }

        if selectedIndex == removeIndex && !searchSettingsModel.ignoreGlobPatterns.isEmpty && selectedIndex != nil {
            selection = searchSettingsModel.ignoreGlobPatterns[
                selectedIndex == 0 ? 0 : (selectedIndex ?? 1) - 1
            ]
        }
    }
}
