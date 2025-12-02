//
//  GlobPatternListItem.swift
//  CodeEdit
//
//  Created by Esteban on 2/2/24.
//

import SwiftUI

struct GlobPatternListItem: View {
    @Binding var pattern: GlobPattern
    @Binding var selection: Set<UUID>
    var addPattern: () -> Void
    var removePatterns: (_ selection: Set<UUID>?) -> Void
    var focusedField: FocusState<String?>.Binding
    var isLast: Bool

    @State var value: String

    @FocusState private var isFocused: Bool

    init(
        pattern: Binding<GlobPattern>,
        selection: Binding<Set<UUID>>,
        addPattern: @escaping () -> Void,
        removePatterns: @escaping (_ selection: Set<UUID>?) -> Void,
        focusedField: FocusState<String?>.Binding,
        isLast: Bool
    ) {
        self._pattern = pattern
        self._selection = selection
        self.addPattern = addPattern
        self.removePatterns = removePatterns
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
                if !value.isEmpty {
                    if isLast {
                        addPattern()
                    }
                }
            }
            .onChange(of: isFocused) { _, newIsFocused in
                if newIsFocused {
                    if !selection.contains(pattern.id) {
                        selection = [pattern.id]
                    }
                } else if value.isEmpty {
                    removePatterns(selection)
                } else if pattern.value != value {
                    pattern.value = value
                }
            }
    }
}
