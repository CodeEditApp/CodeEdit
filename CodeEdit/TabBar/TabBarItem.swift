//
//  TabBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences
import CodeEditUI

struct TabDivider: View {
    @Environment(\.colorScheme)
    var colorScheme
    let width: CGFloat = 1

    var body: some View {
        Group {
            Rectangle()
        }
        .frame(width: width)
        .foregroundColor(
            Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(colorScheme == .dark ? 0.08 : 0.12)
        )
    }
}

struct TabBarItem: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var isHovering: Bool = false

    @State
    var isHoveringClose: Bool = false

    @State
    var isPressingClose: Bool = false
    
    @State
    var isAppeared: Bool = false

    var item: WorkspaceClient.FileItem
    var windowController: NSWindowController

    func switchAction() {
        workspace.selectionState.selectedId = item.id
    }
    
    func closeAction() {
        withAnimation(.easeOut(duration: 0.12)) {
            workspace.closeFileTab(item: item)
        }
    }

    @ObservedObject
    var workspace: WorkspaceDocument

    var tabBarHeight: Double = 28.0

    var isActive: Bool {
        item.id == workspace.selectionState.selectedId
    }

    @ViewBuilder
    var content: some View {
        HStack(spacing: 0.0) {
            TabDivider()
            HStack(alignment: .center, spacing: 5) {
                ZStack {
                    if isActive {
                        // Create a hidden button, if the tab is selected
                        // and hide the button in the ZStack.
                        Button(action: closeAction) {
                            Text("").hidden()
                        }
                        .frame(width: 0, height: 0)
                        .padding(0)
                        .opacity(0)
                        .keyboardShortcut("w", modifiers: [.command])
                    }
                    Button(action: closeAction) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(isPressingClose ? .primary : .secondary)
                    .background(colorScheme == .dark
                        ? Color(nsColor: .white).opacity(isPressingClose ? 0.32 : isHoveringClose ? 0.18 : 0)
                        : Color(nsColor: .black).opacity(isPressingClose ? 0.29 : isHoveringClose ? 0.11 : 0)
                    )
                    .cornerRadius(2)
                    .accessibilityLabel(Text("Close"))
                    .onHover { hover in
                        isHoveringClose = hover
                    }
                    .pressAction {
                        isPressingClose = true
                    } onRelease: {
                        isPressingClose = false
                    }
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
                }
                Image(systemName: item.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(
                        prefs.preferences.general.fileIconStyle == .color ? item.iconColor : .secondary
                    )
                    .frame(width: 12, height: 12)
                Text(item.url.lastPathComponent)
                    .font(.system(size: 11.0))
                    .lineLimit(1)
            }
            .frame(height: 28)
            .padding(.leading, 4)
            .padding(.trailing, 28)
            .background(
                Color(nsColor: isActive ? .clear : .black)
                    .opacity(
                        colorScheme == .dark
                            ? isHovering ? 0.15 : 0.45
                            : isHovering ? 0.10 : 0.05
                    )
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
            )
            TabDivider()
        }
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
    
    // I am not using Button for wrapping content because Button will potentially have conflict with the inner close Button when the style of this Button is not set to `plain`. And based on the design of CodeEdit, plain style is not an expected choice, so I eventually come up with this solution for now.
    // It is possible to make a customized Button (which may solve the clicking conflict, but I am not sure). I will try that in the future.
    var body: some View {
        content
            .overlay(
                // Use hidden button to keep the behavior of tab shortcut.
                Button(action: switchAction) {
                    EmptyView().hidden()
                }
                .frame(width: 0, height: 0)
                .padding(0)
                .opacity(0)
                .keyboardShortcut(
                    workspace.getTabKeyEquivalent(item: item),
                    modifiers: [.command]
                )
            )
            .background(EffectView(
                material: NSVisualEffectView.Material.titlebar,
                blendingMode: NSVisualEffectView.BlendingMode.withinWindow
            ))
            .onTapGesture(perform: switchAction) // The click event now goes to here.
            .offset(x: isAppeared ? 0 : -18, y: 0)
            .opacity(isAppeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.16)) {
                    isAppeared = true
                }
            }
            .id(item.id)
            .contextMenu {
                Button("Close Tab") {
                    withAnimation {
                        workspace.closeFileTab(item: item)
                    }
                }
                Button("Close Other Tabs") {
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
        for counter in 0..<9 where self.selectionState.openFileItems.count > counter &&
        self.selectionState.openFileItems[counter].fileName == item.fileName {
            return KeyEquivalent.init(
                Character.init("\(counter + 1)")
            )
        }

        return "0"
    }
}
