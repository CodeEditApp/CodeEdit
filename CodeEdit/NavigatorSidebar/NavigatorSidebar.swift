//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct NavigatorSidebar: View {
    @ObservedObject
    var workspace: WorkspaceDocument

    var windowController: NSWindowController

    @State
    private var selection: Int = 0

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigator(workspace: workspace, windowController: windowController)
            case 2:
                FindNavigator(state: workspace.searchState ?? .init(workspace))
            case 7:
                ExtensionNavigator(data: workspace.extensionNavigatorData)
            default:
                Spacer()
            }
        }
        .safeAreaInset(edge: .top) {
            NavigatorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .safeAreaInset(edge: .bottom) {
            NavigatorSidebarToolbarBottom(workspace: workspace)
                .padding(.top, -8)
        }
    }
}
