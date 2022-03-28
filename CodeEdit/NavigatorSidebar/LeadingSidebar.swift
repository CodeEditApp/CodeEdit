//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct LeadingSidebar: View {
    @ObservedObject
    var workspace: WorkspaceDocument

    var windowController: NSWindowController

    @State
    private var selection: Int = 0

    var body: some View {
        ZStack {
            switch selection {
            case 0:
                ProjectNavigator(workspace: workspace, windowController: windowController)
            case 2:
                FindNavigator(state: workspace.searchState ?? .init(workspace))
            default:
                VStack { Spacer() }
            }
        }
        .safeAreaInset(edge: .top) {
            LeadingSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .safeAreaInset(edge: .bottom) {
            LeadingSidebarToolbarBottom(workspace: workspace)
        }
    }
}
