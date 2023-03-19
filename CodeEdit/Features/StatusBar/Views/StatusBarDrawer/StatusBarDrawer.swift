//
//  StatusBarDrawer.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarDrawer: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @Environment(\.colorScheme)
    private var colorScheme

    @State
    private var searchText = ""

    var body: some View {
        if let url = workspace.workspaceFileManager?.folderUrl {
            VStack(spacing: 0) {
                TerminalEmulatorView(url: url)
                HStack(alignment: .center, spacing: 10) {
                    FilterTextField(title: "Filter", text: $searchText)
                        .frame(maxWidth: 300)
                    Spacer()
                    StatusBarClearButton()
                    Divider()
                    StatusBarSplitTerminalButton()
                    StatusBarMaximizeButton()
                }
                .padding(10)
                .frame(maxHeight: 29)
                .background(.bar)
            }
        }
    }
}
