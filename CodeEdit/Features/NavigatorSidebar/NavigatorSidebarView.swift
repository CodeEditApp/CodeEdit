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

    var sidebarAlignment: SidebarToolbarAlignment = .leading

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigatorView()
            case 1:
                SourceControlNavigatorView()
            case 2:
                FindNavigatorView()
            case 7:
                ExtensionNavigatorView()
            default:
                Spacer()
            }
        }
        .padding(.top, sidebarAlignment == .leading ? toolbarPadding : 0)
        .safeAreaInset(edge: .leading) {
            if sidebarAlignment == .leading {
                NavigatorSidebarToolbar(selection: $selection, alignment: sidebarAlignment)
                    .padding(.top, toolbarPadding)
                    .padding(.trailing, toolbarPadding)
            }
        }
        .safeAreaInset(edge: .top) {
            if sidebarAlignment == .top {
                NavigatorSidebarToolbar(selection: $selection, alignment: sidebarAlignment)
                    .padding(.bottom, toolbarPadding)
            } else {
                Divider()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                switch selection {
                case 0:
                    ProjectNavigatorToolbarBottom()
                case 1:
                    SourceControlToolbarBottom()
                default: // TODO: As we implement more sidebars, put their bottom toolbars here.
                    EmptyView()
                }
            }
            .padding(.top, toolbarPadding)
        }
        .environmentObject(workspace)
    }
}

enum SidebarToolbarAlignment {
    case top, leading
}
