//
//  PanelContributionsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import Testing
import CodeEditUI
@testable import CodeEdit

@MainActor
struct PanelContributionsTests {

    /// Ids must be unique within a panel — a duplicate would make selection ambiguous and silently
    /// break the tab bar's layout state, which is keyed by id.
    @Test
    func navigatorContributionIdsAreUnique() {
        let items = navigatorContributions(extensionManager: ExtensionManager())
        #expect(Set(items.map(\.id)).count == items.count)
    }

    /// Order is the contract: first-party tabs keep their existing positions.
    @Test
    func navigatorKeepsItsFirstPartyOrder() {
        let items = navigatorContributions(extensionManager: ExtensionManager())
        #expect(items.map(\.id).prefix(3) == ["project", "sourceControl", "search"])
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

    @Test
    func utilityAreaKeepsItsFirstPartyOrder() {
        let items = utilityAreaContributions(extensionManager: ExtensionManager())
        #expect(items.map(\.id) == ["terminal", "debugConsole", "output"])
    }
}
