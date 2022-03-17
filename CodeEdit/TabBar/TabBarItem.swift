//
//  TabBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct TabBarItem: View {
	var item: WorkspaceClient.FileItem
    var windowController: NSWindowController
    @ObservedObject var workspace: WorkspaceDocument

    var tabBarHeight: Double = 28.0

    var body: some View {
        let isActive = item.id == workspace.selectedId
        
        HStack(spacing: 0.0) {
            FileTabRow(fileItem: item, isSelected: isActive) {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            
            Divider()
        }
        .frame(height: tabBarHeight)
        .foregroundColor(isActive ? .primary : .gray)
    }
}
