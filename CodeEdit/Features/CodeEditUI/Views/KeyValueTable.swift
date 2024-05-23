//
//  KeyValueTable.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/16/24.
//

import SwiftUI

struct KeyValueItem: Identifiable {
    var id: String { key }
    let key: String
    let value: String
}

private struct NewListTableItemView: View {
    @State private var key = ""
    @State private var value = ""
    var completion: (String, String) -> Void

    var body: some View {
        VStack {
            Text("Enter new key-value pair")
            TextField("Key", text: $key)
                .textFieldStyle(.roundedBorder)
            TextField("Value", text: $value)
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
    @State private var showingModal = false
    @State private var selection: KeyValueItem.ID?

    var body: some View {
        let tableItems = items.map { KeyValueItem(key: $0.key, value: $0.value) }

        VStack {
            Table(tableItems, selection: $selection) {
                TableColumn("Key") { item in
                    Text(item.key)
                }
                TableColumn("Value") { item in
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
                NewListTableItemView { key, value in
                    items[key] = value
                    showingModal = false
                }
            }
            .cornerRadius(6)
        }
    }

    private func removeItem() {
        guard let selectedKey = selection else { return }
        items.removeValue(forKey: selectedKey)
        selection = nil
    }
}
