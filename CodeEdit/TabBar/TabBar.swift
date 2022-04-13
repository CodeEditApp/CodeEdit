//
//  TabBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient
import CodeEditUI

struct TabBar: View {
    @Environment(\.colorScheme)
    var colorScheme

    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    var tabBarHeight = 28.0

    var body: some View {
        VStack(spacing: 0.0) {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(
                        Color(nsColor: .black).opacity(colorScheme == .dark ? 0.45 : 0.05)
                    )
                    .frame(height: 28)
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { value in
                        HStack(alignment: .center, spacing: -1) {
                            ForEach(workspace.selectionState.openFileItems, id: \.id) { item in
                                TabBarItem(
                                    item: item,
                                    windowController: windowController,
                                    workspace: workspace
                                )
                            }
                        }
                        .onAppear {
                            value.scrollTo(self.workspace.selectionState.selectedId)
                        }
                    }
                }
                .padding(.leading, -1)
            }
        }
        .background(
            BlurView(
                material: NSVisualEffectView.Material.titlebar,
                blendingMode: NSVisualEffectView.BlendingMode.withinWindow
            )
        )
    }
}
