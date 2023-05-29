//
//  InspectorTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 25/03/2023.
//

import Foundation
import CodeEditKit
import ExtensionKit

enum InspectorTab: Hashable, Identifiable {
    case file
    case gitHistory
    case quickhelp
    case uiExtension(endpoint: AppExtensionIdentity, data: ResolvedSidebar.SidebarStore)

    var systemImage: String {
        switch self {
        case .file:
            return "doc"
        case .gitHistory:
            return "clock"
        case .quickhelp:
            return "questionmark.circle"
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
        case .file:
            return "File Inspector"
        case .gitHistory:
            return "History Inspector"
        case .quickhelp:
            return "Quick Help Inspector"
        case .uiExtension(_, let data):
            return data.help ?? data.sceneID
        }
    }
}
