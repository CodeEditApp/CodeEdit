//
//  EnvironmentVariableListItem.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI

struct EnvironmentVariableListItem: View {
    @FocusState private var isKeyFocused: Bool

    @Binding var environmentVariable: CETask.EnvironmentVariable
    @Binding var selectedEnvID: UUID?

    /// State variables added to prevent an exception when deleting the item in the onChange event.
    @State var key: String
    @State var value: String

    var delete: (UUID) -> Void

    init(
        environmentVariable: Binding<CETask.EnvironmentVariable>,
        selectedEnvID: Binding<UUID?>,
        deleteHandler: @escaping (UUID) -> Void
    ) {
        self.delete = deleteHandler

        self._key = State(wrappedValue: environmentVariable.key.wrappedValue)
        self._value = State(wrappedValue: environmentVariable.value.wrappedValue)
        self._environmentVariable = environmentVariable
        self._selectedEnvID = selectedEnvID
    }
    var body: some View {
        HStack {
            TextField("", text: $key)
                .focused($isKeyFocused)
                .disableAutocorrection(true)
                .autocorrectionDisabled()
                .labelsHidden()
                .frame(width: 120)
                .onAppear {
                    if environmentVariable.key.isEmpty {
                        isKeyFocused = true
                    }
                }
            Divider()
            TextField("", text: $value)
                .disableAutocorrection(true)
                .autocorrectionDisabled()
                .labelsHidden()
        }
        .onChange(of: isKeyFocused) { _, isFocused in
            if isFocused {
                if selectedEnvID != environmentVariable.id {
                    selectedEnvID = environmentVariable.id
                }
            } else {
                if key.isEmpty {
                    selectedEnvID = nil
                    delete(environmentVariable.id)
                }
            }
        }
        .onChange(of: key) { _, newValue in
            environmentVariable.key = newValue
        }
        .onChange(of: value) { _, newValue in
            environmentVariable.value = newValue
        }
    }
}

// #Preview {
//    EnvironmentVariableListItem()
// }
