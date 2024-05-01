//
//  IgnorePatternListItemView.swift
//  CodeEdit
//
//  Created by Esteban on 2/2/24.
//

import SwiftUI

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
