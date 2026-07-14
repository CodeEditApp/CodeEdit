//
//  SourceControlNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import CESourceControl
import SwiftUI
import CodeEditUI

struct SourceControlNavigatorToolbarBottom: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @EnvironmentObject var sourceControlViewModel: SourceControlViewModel

    @State private var text = ""

    var body: some View {
        HStack(spacing: 5) {
            sourceControlMenu
            PaneTextField(
                "Filter",
                text: $text,
                leadingAccessories: {
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
                },
                clearable: true
            )
        }
        .frame(height: 28, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5)
        .overlay(alignment: .top) {
            Divider()
                .opacity(0)
        }
    }

    private var sourceControlMenu: some View {
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
