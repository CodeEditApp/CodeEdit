//
//  TabBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct TabBar: View {
    var windowController: NSWindowController
    @ObservedObject var workspace: WorkspaceDocument

	var tabBarHeight = 28.0

    var body: some View {
        VStack(spacing: 0.0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { value in
                    HStack(alignment: .center, spacing: 0.0) {
                        ForEach(workspace.openFileItems, id: \.id) { item in
                            let isActive = workspace.selectedId == item.id
                            
                            Button(action: { workspace.selectedId = item.id }) {
                                if isActive {
                                    TabBarItem(item: item, windowController: windowController, workspace: workspace)
                                        .background(Material.bar)
                                } else {
                                    TabBarItem(item: item, windowController: windowController, workspace: workspace)
                                }
                            }
                            .animation(.easeOut(duration: 0.2), value: workspace.openFileItems)
                            .buttonStyle(.plain)
                            .id(item.id)
                        }
                    }
                    .onChange(of: workspace.selectedId) { newValue in
                        withAnimation {
                            value.scrollTo(newValue)
                        }
                    }
                }
            }
            
            Divider()
                .foregroundColor(.gray)
                .frame(height: 1.0)
        }
        .background(Material.regular)
    }

	
}
