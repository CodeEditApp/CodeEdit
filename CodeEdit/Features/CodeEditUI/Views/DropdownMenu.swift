//
//  DropdownMenu.swift
//  CodeEdit
//
//  Created by Axel Martinez on 12/2/24.
//

import SwiftUI

/// A view that shows a custom dropdown menu
struct DropdownMenu<Items: View, Options: View>: View {
    let icon: String
    let options: Options

    var selectedItem: String?
    var status: Color?
    var items: Items

    @State private var isPresented: Bool = false

    init(
        icon: String,
        selectedItem: String? = nil,
        status: Color? = nil,
        @ViewBuilder items: @escaping () -> Items,
        @ViewBuilder options: @escaping() -> Options
    ) {
        self.icon = icon
        self.selectedItem = selectedItem
        self.status = status
        self.items = items()
        self.options = options()
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .imageScale(.medium)
            Text(selectedItem ?? "")
            if let status = status {
                Circle()
                    .fill(status)
                    .frame(width: 5, height: 5)
            }
        }
        .font(.caption)
        .popover(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 0) {
                items
                    .cornerRadius(5)
                Divider()
                    .padding(.vertical, 5)
                options
                    .cornerRadius(5)
            }
            .padding(5)
            .frame(width: 215)
        }.onTapGesture {
            self.isPresented.toggle()
        }
    }
}
