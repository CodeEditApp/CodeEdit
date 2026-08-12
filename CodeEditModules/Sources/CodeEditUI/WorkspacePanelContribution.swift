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
    var content: AnyView { get }
}
