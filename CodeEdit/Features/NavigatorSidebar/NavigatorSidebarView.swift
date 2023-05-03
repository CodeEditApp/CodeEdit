//
//  NavigatorSidebarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebarView: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    @State
    private var selection: Int = 0

    private let toolbarPadding: Double = -8.0

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    @AppSettings(\.general.navigatorTabBarPosition) var sidebarPosition: SettingsData.SidebarTabBarPosition

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigatorView()
            case 1:
                SourceControlNavigatorView()
            case 2:
                FindNavigatorView()
            default:
                Spacer()
            }
        }
        .padding(.top, sidebarPosition == .side ? toolbarPadding : 0)
        .safeAreaInset(edge: .leading) {
            if sidebarPosition == .side {
                NavigatorSidebarTabBar(selection: $selection, position: sidebarPosition)
                    .padding(.top, toolbarPadding)
                    .padding(.trailing, toolbarPadding)
            }
        }
        .safeAreaInset(edge: .top) {
            if sidebarPosition == .top {
                NavigatorSidebarTabBar(selection: $selection, position: sidebarPosition)
                    .padding(.bottom, toolbarPadding)
            } else {
                Divider()
            }
        }
        .environmentObject(workspace)
    }
}
