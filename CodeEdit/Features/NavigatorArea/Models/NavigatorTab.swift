//
//  NavigatorTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/06/2023.
//

import SwiftUI
import CodeEditKit
import ExtensionFoundation

enum NavigatorTab: AreaTab, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.title) { transferable in
            switch transferable {
            case "Project": .project
            case "Version Control": .sourceControl
            case "Search": .search
            default: throw XPCError.extensionDoesNotExist(description: "")
            }
        }
    }

    case project
    case sourceControl
    case search
    case uiExtension(endpoint: AppExtensionIdentity, data: ResolvedSidebar.SidebarStore)

    var icon: Image {
        switch self {
        case .project:
            return Image(systemName: "folder")
        case .sourceControl:
            return Image(symbol: "vault")
        case .search:
            return Image(systemName: "magnifyingglass")
        case .uiExtension(_, let data):
            return Image(systemName: data.icon ?? "e.square")
        }
    }

    var systemImage: String {
        switch self {
        case .project:
            return "folder"
        case .sourceControl:
            return "vault"
        case .search:
            return "magnifyingglass"
        case .uiExtension(_, let data):
            return data.icon ?? "e.square"
        }
    }

    var id: String {
        if case .uiExtension(let endpoint, let data) = self {
            return endpoint.bundleIdentifier + data.sceneID
        }
        return title
    }

    var title: String {
        switch self {
        case .project:
            return "Project"
        case .sourceControl:
            return "Version Control"
        case .search:
            return "Search"
        case .uiExtension(_, let data):
            return data.help ?? data.sceneID
        }
    }

    var body: some View {
        switch self {
        case .project:
            ProjectNavigatorView()
        case .sourceControl:
            SourceControlNavigatorView()
        case .search:
            FindNavigatorView()
        case let .uiExtension(endpoint, data):
            ExtensionSceneView(with: endpoint, sceneID: data.sceneID)
        }
    }
}

import UniformTypeIdentifiers

extension UTType {
    static let navigatorTab: UTType = UTType(exportedAs: "navigatorTab")
}
