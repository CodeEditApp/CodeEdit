//
//  StatusBarDrawer.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarDrawer: View {
    @EnvironmentObject
    private var model: StatusBarViewModel

    @State
    private var searchText = ""

    var height: CGFloat {
        if model.isMaximized {
            return model.maxHeight
        }
        if model.isExpanded {
            return model.currentHeight
        }
        return 0
    }

    var body: some View {
        VStack(spacing: 0) {
            switch model.selectedTab {
            case 0: TerminalEmulatorView(url: model.workspaceURL)
            default: Rectangle().foregroundColor(Color(nsColor: .textBackgroundColor))
            }
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
        .frame(
            minHeight: 0,
            idealHeight: height,
            maxHeight: height
        )
    }
}
