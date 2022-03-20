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
    
    var isActive: Bool {
        item.id == workspace.selectedId
    }
    
    @ViewBuilder
    var content: some View {
        HStack(spacing: 0.0) {
            FileTabRow(fileItem: item, isSelected: isActive, isHovering: isHovering) {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            Divider()
        }
        .background(
            Color(nsColor: .secondaryLabelColor)
                .opacity(!isActive && isHovering ? 0.11 : 0)
                .animation(.easeInOut(duration: 0.15))
        )
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
    
    var body: some View {
        Button(action: { workspace.selectedId = item.id }) {
            content
                .background(
                    isActive ? AnyView(BlurView(
                        material: NSVisualEffectView.Material.titlebar,
                        blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                    )) : AnyView(EmptyView())
                )
        }
        .animation(.easeOut(duration: 0.2), value: workspace.openFileItems)
        .buttonStyle(.plain)
        .id(item.id)
        .keyboardShortcut(
            workspace.getTabKeyEquivalent(item: item),
            modifiers: [.command]
        )
        .contextMenu {
            Button("Close Tab") {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            Button("Close Other Tab") {
                withAnimation {
                    workspace.closeFileTab(where: { $0.id != item.id })
                }
            }
            Button("Close Tabs to the Right") {
                withAnimation {
                    workspace.closeFileTabs(after: item)
                }
            }
        }
    }
}

fileprivate extension WorkspaceDocument {
    func getTabKeyEquivalent(item: WorkspaceClient.FileItem) -> KeyEquivalent {
        for counter in 0..<9 where self.openFileItems.count > counter &&
        self.openFileItems[counter].fileName == item.fileName {
            return KeyEquivalent.init(
                Character.init("\(counter + 1)")
            )
        }

        return "0"
    }
}
