//
//  TabBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct CustomDivider: View {
    @Environment(\.colorScheme) var colorScheme
    let height: CGFloat = 1

    var body: some View {
        Group {
            Rectangle()
        }
        .frame(height: height)
        .foregroundColor(colorScheme == .dark ? Color(nsColor: .black) : Color(nsColor: .separatorColor))
    }
}

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
                            TabBarItem(
                                item: item,
                                windowController: windowController,
                                workspace: workspace
                            )
                        }
                    }
                    .onAppear {
                        value.scrollTo(self.workspace.selectedId)
                    }
                }
            }
        }
        .background(BlurView(material: NSVisualEffectView.Material.windowBackground,
                             blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
    }
}
