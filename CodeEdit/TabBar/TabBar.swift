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
                            .keyboardShortcut(
                                self.getTabId(fileName: item.fileName),
                                modifiers: [.command]
                            )
                        }
                    }
                    .onAppear {
                        value.scrollTo(self.workspace.selectedId)
                    }
                }
            }
            
            Divider()
                .foregroundColor(.gray)
                .frame(height: 1.0)
        }
        .background(Material.regular)
    }

    func getTabId(fileName: String) -> KeyEquivalent {
        var tabID = 0

        for i in 0..<10 {
            if workspace.openFileItems.count > i,
               workspace.openFileItems[i].fileName == fileName {
                tabID = i + 1
            }
        }

        switch tabID {
        case 1:
            return "1"

        case 2:
            return "2"

        case 3:
            return "3"

        case 4:
            return "4"

        case 5:
            return "5"

        case 6:
            return "6"

        case 7:
            return "7"

        case 8:
            return "8"

        case 9:
            return "9"

        default:
            return "0"
        }
    }
}
