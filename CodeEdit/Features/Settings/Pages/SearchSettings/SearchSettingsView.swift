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
                        removePattern(pattern)
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
}

struct IgnorePatternListItem: View {
    @Binding var pattern: GlobPattern
    @Binding var selectedPattern: GlobPattern?
    var addPattern: () -> Void
    var removePattern: (GlobPattern) -> Void
    var focusedField: FocusState<String?>.Binding
    var isLast: Bool

    @State var value: String

    @FocusState private var isFocused: Bool

    init(
        pattern: Binding<GlobPattern>,
        selectedPattern: Binding<GlobPattern?>,
        addPattern: @escaping () -> Void,
        removePattern: @escaping (GlobPattern) -> Void,
        focusedField: FocusState<String?>.Binding,
        isLast: Bool
    ) {
        self._pattern = pattern
        self._selectedPattern = selectedPattern
        self.addPattern = addPattern
        self.removePattern = removePattern
        self.focusedField = focusedField
        self.isLast = isLast
        self._value = State(initialValue: pattern.wrappedValue.value)
    }

    var body: some View {
        TextField("", text: $value)
            .focused(focusedField, equals: pattern.id.uuidString)
            .focused($isFocused)
            .disableAutocorrection(true)
            .autocorrectionDisabled()
            .labelsHidden()
            .onSubmit {
                if !value.isEmpty && isLast {
                    addPattern()
                }
            }
            .onChange(of: isFocused) { newIsFocused in
                if newIsFocused {
                    if selectedPattern != pattern {
                        selectedPattern = pattern
                    }
                } else {
                    if value.isEmpty {
                        removePattern(pattern)
                    } else {
                        pattern.value = value
                    }
                }
            }
    }
}
