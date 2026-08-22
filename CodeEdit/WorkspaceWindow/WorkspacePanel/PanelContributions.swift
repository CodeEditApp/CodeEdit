//
//  PanelContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CESearch
import CESourceControl
import CodeEditCore
import CodeEditUI

/// The ids of the first-party panel tabs.
///
/// Selecting a tab means assigning its id, so these exist to keep every call site that does so
/// compile-checked. A bare string typo is silent: guarded sites become a no-op, unguarded ones
/// select an id no contribution has and the panel renders "No Selection". Extension-provided ids
/// are dynamic and deliberately absent.
enum PanelTabID {
    static let project = "project"
    /// Owned by `CESourceControl.SourceControlNavigatorContribution`.
    static let sourceControl = SourceControlNavigatorContribution.tabID
    /// Owned by `CESearch.FindNavigatorContribution`, which vends the tab this id selects — kept
    /// as one source of truth rather than duplicated as a literal.
    static let search = FindNavigatorContribution.tabID

    static let file = "file"
    /// Owned by `CESourceControl.GitHistoryInspectorContribution`.
    static let gitHistory = GitHistoryInspectorContribution.tabID
    static let internalDevelopment = "internalDevelopment"

    static let terminal = "terminal"
    static let debugConsole = "debugConsole"
    static let output = "output"
}

/// The `navigator` and `activeEditorState` parameters below are deliberately **required**. A
/// default would let a forgotten injection compile and then fail silently at runtime — a no-op
/// navigator means clicking a changed file does nothing, which no gate can see. Callers with no
/// workspace (tests) pass `CodeEditCore`'s no-op types explicitly, which is a choice rather than an
/// accident.
@MainActor
func navigatorContributions(
    extensionManager: ExtensionManager,
    navigator: WorkspaceNavigator
) -> [any WorkspacePanelContribution] {
    var items: [any WorkspacePanelContribution] = [
        ProjectNavigatorContribution(),
        SourceControlNavigatorContribution(navigator: navigator),
        FindNavigatorContribution()
    ]
    items += extensionContributions(for: .navigator, from: extensionManager)
    return items
}

@MainActor
func inspectorContributions(
    extensionManager: ExtensionManager,
    showInternalDevelopment: Bool,
    activeEditorState: ActiveEditorState
) -> [any WorkspacePanelContribution] {
    var items: [any WorkspacePanelContribution] = [
        FileInspectorContribution(),
        GitHistoryInspectorContribution(activeEditorState: activeEditorState)
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
