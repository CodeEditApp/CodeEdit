//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebar: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    private let windowController: NSWindowController

    @State
    private var selection: Int = 0

    private let toolbarPadding: Double = -8.0

    init(workspace: WorkspaceDocument, windowController: NSWindowController) {
        self.workspace = workspace
        self.windowController = windowController
    }

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigator(workspace: workspace, windowController: windowController)
            case 1:
                SourceControlNavigatorView(workspace: workspace)
            case 2:
                FindNavigator(workspace: workspace, state: workspace.searchState ?? .init(workspace))
            case 7:
                ExtensionNavigator(data: workspace.extensionNavigatorData)
                    .environmentObject(workspace)
            default:
                Spacer()
            }
        }
        .safeAreaInset(edge: .top) {
            NavigatorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, toolbarPadding)
        }
        .safeAreaInset(edge: .bottom) {
            switch selection {
            case 0:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            case 1:
                SourceControlToolbarBottom()
                    .padding(.top, toolbarPadding)
            case 2:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            case 7:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            default:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            }
        }
    }
}
