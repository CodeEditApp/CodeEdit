//
//  KeyValueTable.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/16/24.
//

import SwiftUI

struct KeyValueItem: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let value: String
}

private struct NewListTableItemView<HeaderView: View>: View {
    @Environment(\.dismiss)
    var dismiss

    @State private var key = ""
    @State private var value = ""

    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String
    let validKeys: [String]
    let headerView: HeaderView?
    var completion: (String, String) -> Void

    init(
        key: String? = nil,
        value: String? = nil,
        _ keyColumnName: String,
        _ valueColumnName: String,
        _ newItemInstruction: String,
        validKeys: [String],
        headerView: HeaderView? = nil,
        completion: @escaping (String, String) -> Void
    ) {
        self.key = key ?? ""
        self.value = value ?? ""
        self.keyColumnName = keyColumnName
        self.valueColumnName = valueColumnName
        self.newItemInstruction = newItemInstruction
        self.validKeys = validKeys
        self.headerView = headerView
        self.completion = completion
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    if validKeys.isEmpty {
                        TextField(keyColumnName, text: $key)
                            .textFieldStyle(.plain)
                    } else {
                        Picker(keyColumnName, selection: $key) {
                            ForEach(validKeys, id: \.self) { key in
                                Text(key).tag(key)
                            }
                            Divider()
                            Text("No Selection").tag("")
                        }
                    }
                    TextField(valueColumnName, text: $value)
                        .textFieldStyle(.plain)
                } header: {
                    if HeaderView.self == EmptyView.self {
                        Text(newItemInstruction)
                    } else {
                        headerView
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .onSubmit {
                if !key.isEmpty && !value.isEmpty {
                    completion(key, value)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Add") {
                    if !key.isEmpty && !value.isEmpty {
                        completion(key, value)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(key.isEmpty || value.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: 500)
    }
}

struct KeyValueTable<Header: View, ActionBarView: View>: View {
    @Binding var items: [String: String]

    let validKeys: [String]
    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String
    let newItemHeader: () -> Header
    let actionBarTrailing: () -> ActionBarView

    @State private var editingItem: KeyValueItem?
    @State private var selection: Set<UUID> = []
    @State private var tableItems: [KeyValueItem] = []

    init(
        items: Binding<[String: String]>,
        validKeys: [String] = [],
        keyColumnName: String,
        valueColumnName: String,
        newItemInstruction: String,
        @ViewBuilder newItemHeader: @escaping () -> Header = { EmptyView() },
        @ViewBuilder actionBarTrailing: @escaping () -> ActionBarView = { EmptyView() }
    ) {
        self._items = items
        self.validKeys = validKeys
        self.keyColumnName = keyColumnName
        self.valueColumnName = valueColumnName
        self.newItemInstruction = newItemInstruction
        self.newItemHeader = newItemHeader
        self.actionBarTrailing = actionBarTrailing
    }

    var body: some View {
        Table(tableItems, selection: $selection) {
            TableColumn(keyColumnName) { item in
                Text(item.key)
            }
            TableColumn(valueColumnName) { item in
                Text(item.value)
            }
        }
        .contextMenu(
            forSelectionType: UUID.self,
            menu: { selectedItems in
                Button("Edit") {
                    editItem(id: selectedItems.first)
                }
                Button("Remove") {
                    removeItem(selectedItems)
                }
            },
            primaryAction: { selectedItems in
                editItem(id: selectedItems.first)
            }
        )
        .actionBar {
            HStack(spacing: 2) {
                Button {
                    editingItem = KeyValueItem(key: "", value: "")
                } label: {
                    Image(systemName: "plus")
                }

                Divider()
                    .frame(minHeight: 15)

                Button {
                    removeItem()
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection.isEmpty)
                .opacity(selection.isEmpty ? 0.5 : 1)

                Spacer()

                actionBarTrailing()
            }
        }
        .sheet(item: $editingItem) { item in
            NewListTableItemView(
                key: item.key,
                value: item.value,
                keyColumnName,
                valueColumnName,
                newItemInstruction,
                validKeys: validKeys,
                headerView: newItemHeader()
            ) { key, value in
                items[key] = value
                editingItem = nil
            }
        }
        .cornerRadius(6)
        .onAppear {
            updateTableItems(items)
            if let first = tableItems.first?.id {
                selection = [first]
            }
            selection = []
        }
        .onChange(of: items) { newValue in
            updateTableItems(newValue)
        }
    }

    private func updateTableItems(_ newValue: [String: String]) {
        tableItems = items
            .sorted { $0.key < $1.key }
            .map { KeyValueItem(key: $0.key, value: $0.value) }
    }

    private func removeItem() {
        removeItem(selection)
        self.selection.removeAll()
    }

    private func removeItem(_ selection: Set<UUID>) {
        for selectedId in selection {
            if let selectedItem = tableItems.first(where: { $0.id == selectedId }) {
                items.removeValue(forKey: selectedItem.key)
            }
        }
    }

    private func editItem(id: UUID?) {
        guard let id, let item = tableItems.first(where: { $0.id == id }) else {
            return
        }
        editingItem = item
    }
}
