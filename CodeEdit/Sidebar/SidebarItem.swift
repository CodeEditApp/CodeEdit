//
//  SidebarItem.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation
import SwiftUI
import WorkspaceClient

struct SidebarItem: View {
    let item: WorkspaceClient.FileItem
    @Binding var selectedId: UUID?
    let action: (WorkspaceClient.FileItem) -> Void

    var body: some View {
        Button(action: {
            action(item)
        }) {
            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                .accentColor(.secondary)
                .font(.callout)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 3)
        .padding(.horizontal, 5)
        .background(
            selectedId == item.id ? Color.blue : Color.clear
        )
        .cornerRadius(5)
    }

    func generateBackground(selected: Bool) -> AnyView {
        guard !selected else { return AnyView(Color.clear) }
        return AnyView(
            Color.red
                .padding()
                .cornerRadius(10)
        )
    }
}
