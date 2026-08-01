//
//  WorkspacePanelRetentionTests.swift
//  CodeEditTests
//
//  Created by Boris Serzhanovich on 1/8/26.
//

import Testing
import SwiftUI
@testable import CodeEdit

/// Verifies sidebar tab panels stay mounted so AppKit outline state can survive tab switches (#711).
@Suite("Workspace panel retention")
struct WorkspacePanelRetentionTests {

    private struct ProbeTab: WorkspacePanelTab {
        let id: String
        let title: String
        let systemImage: String
        let marker: String

        var body: some View {
            Text(marker)
                .accessibilityIdentifier("ProbeTab-\(id)")
        }
    }

    @MainActor
    private final class ProbeViewModel: ObservableObject {
        @Published var selectedTab: ProbeTab?
        @Published var tabItems: [ProbeTab]
        init(tabs: [ProbeTab], selected: ProbeTab?) {
            self.tabItems = tabs
            self.selectedTab = selected
        }
    }

    @Test
    @MainActor
    func keepsAllTabBodiesMountedWhenSelectionChanges() {
        let project = ProbeTab(id: "project", title: "Project", systemImage: "folder", marker: "PROJECT")
        let search = ProbeTab(id: "search", title: "Search", systemImage: "magnifyingglass", marker: "SEARCH")
        let viewModel = ProbeViewModel(tabs: [project, search], selected: project)

        let view = WorkspacePanelView(
            viewModel: viewModel,
            selectedTab: Binding(
                get: { viewModel.selectedTab },
                set: { viewModel.selectedTab = $0 }
            ),
            tabItems: Binding(
                get: { viewModel.tabItems },
                set: { viewModel.tabItems = $0 }
            ),
            sidebarPosition: .top
        )

        let hosting = NSHostingView(rootView: view.frame(width: 240, height: 320))
        hosting.layoutSubtreeIfNeeded()

        #expect(hostingContains(hosting, text: "PROJECT"))
        #expect(hostingContains(hosting, text: "SEARCH"))

        viewModel.selectedTab = search
        hosting.layoutSubtreeIfNeeded()

        // Both panels remain in the hierarchy after switching — state retention depends on this.
        #expect(hostingContains(hosting, text: "PROJECT"))
        #expect(hostingContains(hosting, text: "SEARCH"))
    }

    @MainActor
    private func hostingContains(_ hosting: NSHostingView<some View>, text: String) -> Bool {
        func search(_ view: NSView) -> Bool {
            if let textField = view as? NSTextField, textField.stringValue.contains(text) {
                return true
            }
            if let textView = view as? NSTextView, textView.string.contains(text) {
                return true
            }
            return view.subviews.contains(where: search)
        }
        return search(hosting)
    }
}
