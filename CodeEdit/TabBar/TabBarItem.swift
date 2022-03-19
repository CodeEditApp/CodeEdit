//
//  TabBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct TabBarItem: View {
    @State var isHovering: Bool = false
	var item: WorkspaceClient.FileItem
    var windowController: NSWindowController
    @ObservedObject var workspace: WorkspaceDocument
    var tabBarHeight: Double = 28.0
    var body: some View {
        let isActive = item.id == workspace.selectedId
        HStack(spacing: 0.0) {
            FileTabRow(fileItem: item, isSelected: isActive, isHovering: isHovering) {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            Divider()
        }
        .background(Color(nsColor: .secondaryLabelColor).opacity(!isActive && isHovering ? 0.11 : 0).animation(.easeInOut(duration: 0.15)))
        .frame(height: tabBarHeight)
        .foregroundColor(isActive ? .primary : .secondary)
        .onHover { hover in
            isHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}
