//
//  PanelContributionsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import Testing
import CodeEditUI
@testable import CodeEdit

/// Parity tests for the three panels' first-party tabs.
///
/// Every expectation is a literal, never derived from `PanelTabID` or from the contribution types
/// themselves — a test that computes its expectation the way the code does would pass through any
/// rename. These titles and SF Symbols are the ones the deleted `NavigatorTab`, `InspectorTab` and
/// `UtilityAreaTab` enums shipped; changing one is a silent visual regression, so it must fail here.
///
/// Only the first-party prefix is asserted: a developer machine may have real extensions installed,
/// which legitimately append tabs.
@MainActor
struct PanelContributionsTests {

    // MARK: - Navigator

    @Test
    func navigatorTabsKeepTheirIdsAndOrder() {
        let items = navigatorContributions(extensionManager: ExtensionManager())
        #expect(items.prefix(3).map(\.id) == ["project", "sourceControl", "search"])
    }

    @Test
    func navigatorTabsKeepTheirTitles() {
        let items = navigatorContributions(extensionManager: ExtensionManager())
        #expect(items.prefix(3).map(\.title) == ["Project", "Source Control", "Search"])
    }

    @Test
    func navigatorTabsKeepTheirSymbols() {
        let items = navigatorContributions(extensionManager: ExtensionManager())
        #expect(items.prefix(3).map(\.systemImage) == ["folder", "vault", "magnifyingglass"])
    }

    // MARK: - Inspector

    @Test
    func inspectorTabsKeepTheirIdsAndOrder() {
        let items = inspectorContributions(extensionManager: ExtensionManager(), showInternalDevelopment: true)
        #expect(items.prefix(3).map(\.id) == ["file", "gitHistory", "internalDevelopment"])
    }

    @Test
    func inspectorTabsKeepTheirTitles() {
        let items = inspectorContributions(extensionManager: ExtensionManager(), showInternalDevelopment: true)
        #expect(items.prefix(3).map(\.title) == ["File Inspector", "History Inspector", "Internal Development"])
    }

    @Test
    func inspectorTabsKeepTheirSymbols() {
        let items = inspectorContributions(extensionManager: ExtensionManager(), showInternalDevelopment: true)
        #expect(items.prefix(3).map(\.systemImage) == ["doc", "clock", "hammer"])
    }

    /// The inspector's developer tab is the only conditional contribution.
    @Test
    func inspectorIncludesTheDeveloperTabOnlyWhenEnabled() {
        let disabled = inspectorContributions(
            extensionManager: ExtensionManager(), showInternalDevelopment: false
        )
        let enabled = inspectorContributions(
            extensionManager: ExtensionManager(), showInternalDevelopment: true
        )

        #expect(!disabled.map(\.id).contains("internalDevelopment"))
        #expect(enabled.map(\.id).contains("internalDevelopment"))
        #expect(enabled.count == disabled.count + 1)
    }

    // MARK: - Utility area

    /// `ResolvedSidebar.Kind` has no utility-area case, so this list is always exactly three tabs.
    @Test
    func utilityAreaTabsKeepTheirIdsAndOrder() {
        let items = utilityAreaContributions(extensionManager: ExtensionManager())
        #expect(items.map(\.id) == ["terminal", "debugConsole", "output"])
    }

    @Test
    func utilityAreaTabsKeepTheirTitles() {
        let items = utilityAreaContributions(extensionManager: ExtensionManager())
        #expect(items.map(\.title) == ["Terminal", "Debug Console", "Output"])
    }

    @Test
    func utilityAreaTabsKeepTheirSymbols() {
        let items = utilityAreaContributions(extensionManager: ExtensionManager())
        #expect(items.map(\.systemImage) == ["terminal", "ladybug", "list.bullet.indent"])
    }

    // MARK: - Selection call sites

    /// The four `selectedTabID` call sites assign these constants; if one drifts from the
    /// contribution that owns it, selection silently stops resolving.
    @Test
    func selectionConstantsMatchTheContributionsTheyName() {
        #expect(PanelTabID.search == "search")
        #expect(PanelTabID.debugConsole == "debugConsole")
        #expect(navigatorContributions(extensionManager: ExtensionManager())
            .contains { $0.id == PanelTabID.search })
        #expect(utilityAreaContributions(extensionManager: ExtensionManager())
            .contains { $0.id == PanelTabID.debugConsole })
    }
}
