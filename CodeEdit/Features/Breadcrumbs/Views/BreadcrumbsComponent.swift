//
//  BreadcrumbsComponent.swift
//  CodeEditModules/Breadcrumbs
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI

struct BreadcrumbsComponent: View {

    private let fileItem: WorkspaceClient.FileItem
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var position: NSPoint?

    init(
        fileItem: WorkspaceClient.FileItem,
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
    }

    private var image: String {
        fileItem.parent == nil ? "square.dashed.inset.filled" : fileItem.systemImage
    }

    /// If current `fileItem` has no parent, it's the workspace root directory
    /// else if current `fileItem` has no children, it's the opened file
    /// else it's a folder
    private var color: Color {
        fileItem.parent == nil
        ? .accentColor
        : (
            fileItem.isFolder
            ? Color(hex: colorScheme == .dark ? "#61b6df" :"#27b9ff")
            : fileItem.iconColor
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12)
                .foregroundStyle(
                    prefs.preferences.general.fileIconStyle == .color
                    ? color
                    : .secondary
                )
                .opacity(activeState != .inactive ? 1.0 : 0.4)
            Text(fileItem.fileName)
                .foregroundStyle(.primary)
                .font(.system(size: 11))
                .opacity(activeState != .inactive ? 1.0 : 0.2)
        }
        /// Get location in window
        .background(GeometryReader { (proxy: GeometryProxy) -> Color in
            if position != NSPoint(
                x: proxy.frame(in: .global).minX,
                y: proxy.frame(in: .global).midY
            ) {
                DispatchQueue.main.async {
                    position = NSPoint(
                        x: proxy.frame(in: .global).minX,
                        y: proxy.frame(in: .global).midY
                    )
                }
            }
            return Color.clear
        })
        .onTapGesture {
            if let siblings = fileItem.parent?.children?.sortItems(foldersOnTop: true), !siblings.isEmpty {
                let menu = BreadcrumsMenu(
                    fileItems: siblings
                ) { item in
                    tappedOpenFile(item)
                }
                if let position = position,
                   let windowHeight = NSApp.keyWindow?.contentView?.frame.height {
                    let pos = NSPoint(x: position.x, y: windowHeight - 72) // 72 = offset from top to breadcrumbs bar
                    menu.popUp(positioning: menu.item(withTitle: fileItem.fileName),
                               at: pos,
                               in: NSApp.keyWindow?.contentView)
                }
            }
        }
    }
}
