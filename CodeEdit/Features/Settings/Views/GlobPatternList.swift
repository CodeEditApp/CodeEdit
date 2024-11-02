//
//  GlobPatternList.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/24.
//

import SwiftUI

struct GlobPatternList: View {
    @Binding var patterns: [GlobPattern]
    let selection: Binding<Set<GlobPattern>>
    let addPattern: () -> Void
    let removePatterns: (_ selection: Set<GlobPattern>?) -> Void
    let emptyMessage: String

    @FocusState private var focusedField: String?

    var body: some View {
        List(selection: selection) {
            ForEach(Array(patterns.enumerated()), id: \.element) { index, pattern in
                GlobPatternListItem(
                    pattern: $patterns[index],
                    selection: selection,
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
            .onDelete { _ in
                removePatterns(nil)
            }
        }
        .frame(minHeight: 96)
        .contextMenu(forSelectionType: GlobPattern.self, menu: { selection in
            if let pattern = selection.first {
                Button("Edit") {
                    focusedField = pattern.id.uuidString
                }
                Button("Add") {
                    addPattern()
                }
                Divider()
                Button("Remove") {
                    if !patterns.isEmpty {
                        removePatterns(selection)
                    }
                }
            }
        }, primaryAction: { selection in
            if let pattern = selection.first {
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
                removePatterns(nil)
            } label: {
                Image(systemName: "minus")
                    .opacity(selection.wrappedValue.isEmpty ? 0.5 : 1)
            }
            .disabled(selection.wrappedValue.isEmpty)
        }
        .onDeleteCommand {
            removePatterns(nil)
        }
    }
}
