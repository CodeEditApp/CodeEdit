//
//  NavigatorSidebarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditKit
import ExtensionFoundation

enum SidebarNavigator: Identifiable, Hashable, CaseIterable, CustomStringConvertible {
    case project,
         sourceControl,
         search,
         custom(ExtensionSidebarItem)

    var id: Self { self }

    var icon: Image {
        switch self {
        case .project:
            return Image(systemName: "folder")
        case .sourceControl:
            return Image(nsImage: NSImage.vault)
        case .search:
            return Image(systemName: "magnifyingglass")
        case .custom(let item):
            return Image(systemName: item.icon)
        }
    }

    var description: String {
        switch self {
        case .project:
            return "Project"
        case .sourceControl:
            return "Version Control"
        case .search:
            return "Search"
        case .custom(let item):
            return item.sceneID
        }
    }

    static var allCases: [SidebarNavigator] {
        return [.project, .sourceControl, .search] + ExtensionDiscovery.shared.extensions
            .map(\.sidebars).joined().map { Self.custom($0) }
    }

}

struct NavigatorSidebarView: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    private let windowController: NSWindowController

    @State
    private var selection: SidebarNavigator = .project

    private let toolbarPadding: Double = -8.0

    init(workspace: WorkspaceDocument, windowController: NSWindowController) {
        self.workspace = workspace
        self.windowController = windowController
    }

    var body: some View {
        VStack {
            switch selection {
            case .project:
                ProjectNavigatorView(workspace: workspace, windowController: windowController)
            case .sourceControl:
                SourceControlNavigatorView(workspace: workspace)
            case .search:
                FindNavigatorView(workspace: workspace, state: workspace.searchState ?? .init(workspace))
            case .custom(let item):
                VStack {
                    ExtensionSceneView(with: item.endpoint, sceneID: item.sceneID)
                }
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
            case .project, .search:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            case .sourceControl:
                SourceControlToolbarBottom()
                    .padding(.top, toolbarPadding)

            default:
                NavigatorSidebarToolbarBottom(workspace: workspace)
                    .padding(.top, toolbarPadding)
            }
        }
    }
}
