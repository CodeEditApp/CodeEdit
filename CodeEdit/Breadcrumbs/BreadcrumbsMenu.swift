//
//  BreadcrumbsMenu.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/24.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsMenu: View {
    /// The current `WorkspaceDocument`
    @ObservedObject var workspace: WorkspaceDocument

    /// The parent of `FileItem` for this view
    private var parentFileItem: WorkspaceClient.FileItem?

    /// File name
    private let title: String

    /// File icon
    private let image: String

    /// File icon's color
    private let color: Color

    init(
        _ workspace: WorkspaceDocument,
        title: String,
        systemImage image: String,
        color: Color = .secondary,
        parentFileItem: WorkspaceClient.FileItem? = nil
    ) {
        self.workspace = workspace
        self.title = title
        self.image = image
        self.color = color
        self.parentFileItem = parentFileItem
    }

    var body: some View {
        // Unable to set image's color in Menu, so using this tricky way.
        ZStack {
            BreadcrumbsComponent(self.title, systemImage: self.image, color: self.color)
            Menu {
                if let siblings = parentFileItem?.children?.sortItems(foldersOnTop: true) {
                    ForEach(siblings, id: \.self) { item in
                        BreadcrumbsMenuItem(workspace: workspace, fileItem: item)
                    }
                }
            } label: {
                EmptyView()
            }
            .menuIndicator(.hidden)
            .menuStyle(.borderlessButton)
        }
    }
}
