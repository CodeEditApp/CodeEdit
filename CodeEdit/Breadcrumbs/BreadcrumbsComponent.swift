//
//  BreadcrumbsComponent.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsComponent: View {
	@AppStorage(FileIconStyle.storageKey)
	var iconStyle: FileIconStyle = .default

    @ObservedObject
	var workspace: WorkspaceDocument

    private let fileItem: WorkspaceClient.FileItem

    @State
	var position: NSPoint?
	
    private let menuHelper: BreadcrumbsMenuHelper

    init(_ workspace: WorkspaceDocument, fileItem: WorkspaceClient.FileItem) {
        self.workspace = workspace
        self.fileItem = fileItem
        self.menuHelper = BreadcrumbsMenuHelper(onOpenFile: { fileItem in
            workspace.openFile(item: fileItem)
        })
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
        : fileItem.children?.isEmpty ?? true
        ? fileItem.iconColor
        : .secondary
    }

	var body: some View {
        HStack(alignment: .center) {
            GeometryReader { geometry in
                HStack {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                        .foregroundStyle(iconStyle == .color ? color : .secondary)
                        .onAppear {
                            self.position = NSPoint(
                                x: geometry.frame(in: .global).minX,
                                y: geometry.frame(in: .global).midY
                            )
                        }
                }.frame(height: geometry.size.height)
            }
            Text(fileItem.fileName)
				.foregroundStyle(.primary)
				.font(.system(size: 11))
                .fixedSize()
                .layoutPriority(1)
		}
        .onTapGesture {
            if let siblings = fileItem.parent?.children?.sortItems(foldersOnTop: true), !siblings.isEmpty {
                let menu = BreadcrumsMenu(siblings, workspace: workspace)
                if let position = position {
                    menu.popUp(positioning: menu.item(withTitle: fileItem.fileName),
                               at: position,
                               in: NSApp.keyWindow?.contentView)
                }
            }
        }
	}
}

class BreadcrumbsMenuHelper {

    var onOpenFile: (WorkspaceClient.FileItem) -> Void

    init(onOpenFile: @escaping (WorkspaceClient.FileItem) -> Void) {
        self.onOpenFile = onOpenFile
    }

    @objc func openFile(_ sender: NSMenuItem) {
        if let fileItem = sender.representedObject as? WorkspaceClient.FileItem {
            self.onOpenFile(fileItem)
        }
    }
}
