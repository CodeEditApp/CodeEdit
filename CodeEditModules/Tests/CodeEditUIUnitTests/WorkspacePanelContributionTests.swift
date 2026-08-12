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
}
