//
//  EnvironmentVariableListItem.swift
//  CodeEdit
//
//  Created by Axel Martinez on 9/4/24.
//

import SwiftUI

struct EnvironmentVariableListItem: View {
    @FocusState private var isKeyFocused: Bool

    @Binding var item: CETask.EnvironmentVariable
    @Binding var selectedItemId: UUID?

    /// State variables added to prevent an exception when deleting the item in the onChange event.
    @State var name: String
    @State var value: String

    var delete: (UUID) -> Void

    init(
        item: Binding<CETask.EnvironmentVariable>,
        selectedItemId: Binding<UUID?>,
        deleteHandler: @escaping (UUID) -> Void
    ) {
        self.delete = deleteHandler

        self._name = State(wrappedValue: item.name.wrappedValue)
        self._value = State(wrappedValue: item.value.wrappedValue)
        self._item = item
        self._selectedItemId = selectedItemId
    }

    var body: some View {
        HStack {
            TextField("", text: $name)
                .focused($isKeyFocused)
                .disableAutocorrection(true)
                .autocorrectionDisabled()
                .labelsHidden()
                .frame(width: 120)
                .onAppear {
                    if item.name.isEmpty {
                        isKeyFocused = true
                    }
                }
            Divider()
            TextField("", text: $value)
                .disableAutocorrection(true)
                .autocorrectionDisabled()
                .labelsHidden()
        }
        .onChange(of: isKeyFocused) { isFocused in
            if isFocused {
                if selectedItemId != item.id {
                    selectedItemId = item.id
                }
            } else {
                if name.isEmpty {
                    selectedItemId = nil
                    delete(item.id)
                } else {
                    item.name = name
                    item.value = value
                }
            }
        }
    }
}
