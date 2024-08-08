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

private struct NewListTableItemView: View {
    @Environment(\.dismiss)
    var dismiss

    @State private var key = ""
    @State private var value = ""

    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String
    let validKeys: [String]
    let headerView: AnyView?
    var completion: (String, String) -> Void

    init(
        _ keyColumnName: String,
        _ valueColumnName: String,
        _ newItemInstruction: String,
        validKeys: [String],
        headerView: AnyView? = nil,
        completion: @escaping (String, String) -> Void
    ) {
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
                    headerView
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

struct KeyValueTable<Header: View>: View {
    @Binding var items: [String: String]

    let validKeys: [String]
    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String
    let header: () -> Header

    @State private var showingModal = false
    @State private var selection: UUID?
    @State private var tableItems: [KeyValueItem] = []

    init(
        items: Binding<[String: String]>,
        validKeys: [String] = [],
        keyColumnName: String,
        valueColumnName: String,
        newItemInstruction: String,
        @ViewBuilder header: @escaping () -> Header = { EmptyView() }
    ) {
        self._items = items
        self.validKeys = validKeys
        self.keyColumnName = keyColumnName
        self.valueColumnName = valueColumnName
        self.newItemInstruction = newItemInstruction
        self.header = header
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
        .frame(height: 200)
        .actionBar {
            HStack(spacing: 2) {
                Button {
                    showingModal = true
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
                .disabled(selection == nil)
                .opacity(selection == nil ? 0.5 : 1)
            }
            Spacer()
        }
        .sheet(isPresented: $showingModal) {
            NewListTableItemView(
                keyColumnName,
                valueColumnName,
                newItemInstruction,
                validKeys: validKeys,
                headerView: AnyView(header())
            ) { key, value in
                items[key] = value
                updateTableItems()
                showingModal = false
            }
        }
        .cornerRadius(6)
        .onAppear(perform: updateTableItems)
    }

    private func updateTableItems() {
        tableItems = items.map { KeyValueItem(key: $0.key, value: $0.value) }
    }

    private func removeItem() {
        guard let selectedId = selection else { return }
        if let selectedItem = tableItems.first(where: { $0.id == selectedId }) {
            items.removeValue(forKey: selectedItem.key)
            updateTableItems()
        }
        selection = nil
    }
}
