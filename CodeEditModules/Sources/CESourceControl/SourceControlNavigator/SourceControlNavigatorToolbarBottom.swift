//
//  SourceControlNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditUI

struct SourceControlNavigatorToolbarBottom: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @EnvironmentObject var sourceControlViewModel: SourceControlViewModel

    @State private var text = ""

    var body: some View {
        NavigatorFilterView(
            text: $text,
            menu: { sourceControlMenu },
            leadingAccessories: { leadingAccessories },
            trailingAccessories: { EmptyView() }
        )
    }

    @ViewBuilder private var leadingAccessories: some View {
        Image(
            systemName: text.isEmpty
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
        )
        .foregroundStyle(
            text.isEmpty
            ? Color(nsColor: .secondaryLabelColor)
            : Color(nsColor: .controlAccentColor)
        )
        .padding(.leading, 4)
        .help("Filter Changes Navigator")
    }

    @ViewBuilder private var sourceControlMenu: some View {
        Menu {
            Button("Discard All Changes...") {
                if sourceControlManager.changedFiles.isEmpty {
                    sourceControlViewModel.noChangesToDiscardAlertIsPresented = true
                } else {
                    sourceControlViewModel.discardAllAlertIsPresented = true
                }
            }
            Button("Stash Changes...") {
                if sourceControlManager.changedFiles.isEmpty {
                    sourceControlViewModel.noChangesToStashAlertIsPresented = true
                } else {
                    sourceControlViewModel.stashSheetIsPresented = true
                }
            }
        } label: {}
        .background {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
    }
}
