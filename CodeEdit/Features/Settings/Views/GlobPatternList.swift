//
//  GlobPatternList.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/24.
//

import SwiftUI

struct GlobPatternList: View {
    @Binding var patterns: [GlobPattern]
    @Binding var selection: Set<UUID>
    let addPattern: () -> Void
    let removePatterns: (_ selection: Set<UUID>?) -> Void
    let emptyMessage: String

    @FocusState private var focusedField: String?

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(patterns.enumerated()), id: \.element.id) { index, pattern in
                GlobPatternListItem(
                    pattern: $patterns[index],
                    selection: $selection,
                    addPattern: addPattern,
                    removePatterns: removePatterns,
                    focusedField: $focusedField,
                    isLast: patterns.count == index + 1
                )
                .onAppear {
                    if pattern.value.isEmpty {
                        focusedField = pattern.id.uuidString
                    }
                }
            }
            .onMove { fromOffsets, toOffset in
                patterns.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
            .onDelete { indexSet in
                let patternIDs = indexSet.compactMap { patterns[$0].id }
                    removePatterns(Set(patternIDs))
            }
        }
        .frame(minHeight: 96)
        .contextMenu(forSelectionType: UUID.self, menu: { selection in
            if let patternID = selection.first, let pattern = patterns.first(where: { $0.id == patternID }) {
                Button("Edit") {
                    focusedField = pattern.id.uuidString
                }
                Button("Add") {
                    addPattern()
                }
                Divider()
                Button("Remove") {
                    removePatterns(selection)
                }
            }
        }, primaryAction: { selection in
            if let patternID = selection.first, let pattern = patterns.first(where: { $0.id == patternID }) {
                focusedField = pattern.id.uuidString
            }
        })
        .overlay {
            if patterns.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(Color(.secondaryLabelColor))
            }
        }
        .actionBar {
            Button(action: addPattern) {
                Image(systemName: "plus")
            }
            Divider()
            Button {
                removePatterns(selection)
            } label: {
                Image(systemName: "minus")
                    .opacity(selection.isEmpty ? 0.5 : 1)
            }
            .disabled(selection.isEmpty)
        }
        .onDeleteCommand {
            removePatterns(selection)
        }
    }
}
