//
//  KeyValueTable.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/16/24.
//

import SwiftUI

struct KeyValueItem: Identifiable {
    var id = UUID()
    let key: String
    let value: String
}

private struct NewListTableItemView: View {
    @State private var key = ""
    @State private var value = ""

    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String
    var completion: (String, String) -> Void

    init(
        _ keyColumnName: String,
        _ valueColumnName: String,
        _ newItemInstruction: String,
        completion: @escaping (String, String) -> Void
    ) {
        self.keyColumnName = keyColumnName
        self.valueColumnName = valueColumnName
        self.newItemInstruction = newItemInstruction
        self.completion = completion
    }

    var body: some View {
        VStack {
            Text(newItemInstruction)
            TextField(keyColumnName, text: $key)
                .textFieldStyle(.roundedBorder)
            TextField(valueColumnName, text: $value)
                .textFieldStyle(.roundedBorder)
            Button("Add") {
                if !key.isEmpty && !value.isEmpty {
                    completion(key, value)
                }
            }
        }
        .padding()
    }
}

struct KeyValueTable: View {
    @Binding var items: [String: String]

    let keyColumnName: String
    let valueColumnName: String
    let newItemInstruction: String

    @State private var showingModal = false
    @State private var selection: KeyValueItem.ID?

    var body: some View {
        let tableItems = items.map { KeyValueItem(key: $0.key, value: $0.value) }

        VStack {
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
                    newItemInstruction
                ) { key, value in
                    items[key] = value
                    showingModal = false
                }
            }
            .cornerRadius(6)
        }
    }

    private func removeItem() {
        guard let selectedKey = selection else { return }
        if let selectedItem = items.first(where: { $0.key == selectedKey.uuidString }) {
            items.removeValue(forKey: selectedItem.key)
        }
        selection = nil
    }
}
