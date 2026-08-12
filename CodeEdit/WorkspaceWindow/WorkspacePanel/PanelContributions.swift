//
//  PanelContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CESearch
import CodeEditUI

/// The ids of the first-party panel tabs.
///
/// Selecting a tab means assigning its id, so these exist to keep every call site that does so
/// compile-checked. A bare string typo is silent: guarded sites become a no-op, unguarded ones
/// select an id no contribution has and the panel renders "No Selection". Extension-provided ids
/// are dynamic and deliberately absent.
enum PanelTabID {
    static let project = "project"
    static let sourceControl = "sourceControl"
    /// Owned by `CESearch.FindNavigatorContribution`, which vends the tab this id selects — kept
    /// as one source of truth rather than duplicated as a literal.
    static let search = FindNavigatorContribution.tabID

    static let file = "file"
    static let gitHistory = "gitHistory"
    static let internalDevelopment = "internalDevelopment"

    static let terminal = "terminal"
    static let debugConsole = "debugConsole"
    static let output = "output"
}

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
