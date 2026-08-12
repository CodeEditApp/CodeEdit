//
//  PanelContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditUI

@MainActor
func navigatorContributions(
    extensionManager: ExtensionManager
) -> [any WorkspacePanelContribution] {
    var items: [any WorkspacePanelContribution] = [
        ProjectNavigatorContribution(),
        SourceControlNavigatorContribution(),
        FindNavigatorContribution()
    ]
    items += extensionContributions(for: .navigator, from: extensionManager)
    return items
}

@MainActor
func inspectorContributions(
    extensionManager: ExtensionManager,
    showInternalDevelopment: Bool
) -> [any WorkspacePanelContribution] {
    var items: [any WorkspacePanelContribution] = [
        FileInspectorContribution(),
        GitHistoryInspectorContribution()
    ]
    if showInternalDevelopment {
        items.append(InternalDevelopmentInspectorContribution())
    }
    items += extensionContributions(for: .inspector, from: extensionManager)
    return items
}

@MainActor
func utilityAreaContributions(
    extensionManager: ExtensionManager
) -> [any WorkspacePanelContribution] {
    var items: [any WorkspacePanelContribution] = [
        TerminalUtilityContribution(),
        DebugConsoleUtilityContribution(),
        OutputUtilityContribution()
    ]
    items += extensionContributions(for: .utilityArea, from: extensionManager)
    return items
}
