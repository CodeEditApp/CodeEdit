//
//  InspectorTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/06/2023.
//

import SwiftUI
import CodeEditKit
import ExtensionFoundation

enum InspectorTab: WorkspacePanelTab {
    case file
    case gitHistory
    case internalDevelopment
    case uiExtension(endpoint: AppExtensionIdentity, data: ResolvedSidebar.SidebarStore)

    var systemImage: String {
        switch self {
        case .file:
            return "doc"
        case .gitHistory:
            return "clock"
        case .internalDevelopment:
            return "hammer"
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
        case .internalDevelopment:
            return "Internal Development"
        case .uiExtension(_, let data):
            return data.help ?? data.sceneID
        }
    }

    var body: some View {
        switch self {
        case .file:
            FileInspectorView()
        case .gitHistory:
            HistoryInspectorView()
        case .internalDevelopment:
            InternalDevelopmentInspectorView()
        case let .uiExtension(endpoint, data):
            ExtensionSceneView(with: endpoint, sceneID: data.sceneID)
        }
    }
}
