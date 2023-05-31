//
//  NavigatorTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 23/05/2023.
//

import Foundation
import CodeEditKit
import ExtensionKit

enum NavigatorTab: Hashable, Identifiable {
    case fileTree
    case sourceControl
    case search
    case uiExtension(endpoint: AppExtensionIdentity, data: ResolvedSidebar.SidebarStore)

    var systemImage: String {
        switch self {
        case .fileTree:
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
        case .fileTree:
            return "Project"
        case .sourceControl:
            return "Version Control"
        case .search:
            return "Search"
        case .uiExtension(_, let data):
            return data.help ?? data.sceneID
        }
    }
}
