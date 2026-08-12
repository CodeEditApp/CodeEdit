//
//  ExtensionPanelContribution.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditKit
import CodeEditUI
import ExtensionFoundation
import SwiftUI

/// The workspace panel a contribution is assembled for.
enum PanelKind {
    case navigator, inspector, utilityArea
}

/// The sole ExtensionKit-aware contribution.
///
/// One type, constructed once per discovered extension scene. Keeping ExtensionKit's vocabulary
/// here — rather than in the panels — is what lets another contribution source arrive later without
/// the panel code changing.
struct ExtensionPanelContribution: WorkspacePanelContribution {
    let endpoint: AppExtensionIdentity
    let data: ResolvedSidebar.SidebarStore

    /// Note the `.` separator: `bundleIdentifier + sceneID` concatenated without one can collide
    /// between two extensions. Selection is not persisted, so the format change costs nothing.
    var id: String { endpoint.bundleIdentifier + "." + data.sceneID }
    var title: String { data.help ?? data.sceneID }
    var systemImage: String { data.icon ?? "e.square" }
    var content: AnyView { AnyView(ExtensionSceneView(with: endpoint, sceneID: data.sceneID)) }
}

/// Collects every installed extension's scenes that target the given panel.
@MainActor
func extensionContributions(
    for kind: PanelKind,
    from extensionManager: ExtensionManager
) -> [any WorkspacePanelContribution] {
    let sidebarKind: ResolvedSidebar.Kind
    switch kind {
    case .navigator:
        sidebarKind = .navigator
    case .inspector:
        sidebarKind = .inspector
    case .utilityArea:
        // `ResolvedSidebar.Kind` in CodeEditKit declares exactly `case navigator, inspector`
        // (`ResolvedSidebar.swift:14`), so an extension cannot declare a utility-area tab at all.
        // Adding a kind is a change to CodeEditKit, a separate published repo, and is out of scope.
        return []
    }

    return extensionManager
        .extensions
        .flatMap { ext in
            ext.availableFeatures.compactMap { feature -> (any WorkspacePanelContribution)? in
                if case .sidebarItem(let data) = feature, data.kind == sidebarKind {
                    return ExtensionPanelContribution(endpoint: ext.endpoint, data: data)
                }
                return nil
            }
        }
}
