//
//  WorkspacePanelContribution.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import SwiftUI

/// One tab contributed to a workspace panel — the navigator, inspector or utility area.
///
/// A contribution is a value, not a case: first-party features, the app shell itself and installed
/// extensions all vend these, and the panel that renders them cannot tell which is which. That is
/// deliberate — it is what lets a new contribution source arrive without the panel code changing.
///
/// Lives in `CodeEditUI` because it needs SwiftUI and nothing else. It cannot live in
/// `CodeEditCore`, whose charter forbids UI imports.
public protocol WorkspacePanelContribution: Identifiable {
    /// Stable across launches, and unique within a panel.
    ///
    /// Extension-provided ids must be namespaced by their provider so two extensions cannot collide.
    var id: String { get }

    /// Shown in the tab's tooltip and accessibility label.
    var title: String { get }

    /// An SF Symbol name for the tab.
    var systemImage: String { get }

    /// The tab's content.
    ///
    /// Type-erased because a panel holds a heterogeneous list. Erasure happens once per tab, not per
    /// row, and one tab is visible at a time.
    ///
    /// Main-actor isolated because every contribution vends a SwiftUI view, and `View`'s members are
    /// main-actor isolated. Left nonisolated, a conformer in a Swift 6 target warns when it
    /// constructs its own content view — the app target simply doesn't report it, being Swift 5.
    /// Only this requirement is isolated: `id`, `title` and `systemImage` are plain values read from
    /// non-isolated positions.
    @MainActor var content: AnyView { get }

    /// A bar pinned below the tab's content — filters, counts, the navigator's sort controls.
    ///
    /// Defaults to nothing, so a contribution that has no such bar says nothing about it.
    ///
    /// A requirement rather than a parameter the panel is handed: it arrived upstream as a `switch`
    /// over the retired tab enum, where every new tab had to remember to add its case. Vended by the
    /// contribution, a tab cannot forget, and a package can supply one without the panel — which
    /// cannot see the package — knowing it exists.
    ///
    /// Placement is the panel's business, not the tab's: pre-Tahoe it insets the tab's own content,
    /// and from macOS 26 it spans the panel below the tab bar.
    @MainActor var bottomView: AnyView? { get }
}

public extension WorkspacePanelContribution {
    /// Most tabs have no bottom bar.
    @MainActor var bottomView: AnyView? { nil }
}
