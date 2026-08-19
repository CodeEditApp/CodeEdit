//
//  WorkspacePanelContributionTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import Testing
import SwiftUI
@testable import CodeEditUI

private struct StubContribution: WorkspacePanelContribution {
    let id: String
    let title: String
    let systemImage: String
    var content: AnyView { AnyView(Color.clear) }
}

struct WorkspacePanelContributionTests {

    /// A heterogeneous list is the whole point: first-party and extension contributions differ in
    /// type but must live in one array.
    @Test
    func contributionsAreAddressableAsAHeterogeneousList() {
        let items: [any WorkspacePanelContribution] = [
            StubContribution(id: "a", title: "Alpha", systemImage: "a.circle"),
            StubContribution(id: "b", title: "Beta", systemImage: "b.circle")
        ]

        #expect(items.map(\.id) == ["a", "b"])
        #expect(items.first?.title == "Alpha")
    }

    // MARK: - Selection reconciliation

    /// Built per call rather than held in a `static let`: the element type is not `Sendable`, so
    /// shared mutable state would not compile under the package's strict concurrency.
    private func twoTabs() -> [any WorkspacePanelContribution] {
        [
            StubContribution(id: "a", title: "Alpha", systemImage: "a.circle"),
            StubContribution(id: "b", title: "Beta", systemImage: "b.circle")
        ]
    }

    /// A selection that still names a present tab must be left alone — reconciliation runs whenever
    /// the list changes, so a version that "fixed" valid selections would yank the user's tab away
    /// every time an unrelated one appeared.
    @Test
    func keepsASelectionThatStillExists() {
        #expect(twoTabs().reconcilingSelection("b") == "b")
    }

    /// The bug this exists for: the inspector rebuilds its tabs when a setting changes, and a
    /// selection naming the removed tab left the panel on "No Selection" with no way back.
    @Test
    func fallsBackToTheFirstTabWhenTheSelectionIsGone() {
        #expect(twoTabs().reconcilingSelection("removed") == "a")
    }

    @Test
    func selectsTheFirstTabWhenNothingIsSelected() {
        #expect(twoTabs().reconcilingSelection(nil) == "a")
    }

    /// No tabs means no selection — not the previous id, which would keep a dead selection alive.
    @Test
    func answersNilWhenThereAreNoTabs() {
        let empty: [any WorkspacePanelContribution] = []
        #expect(empty.reconcilingSelection("a") == nil)
    }
}
