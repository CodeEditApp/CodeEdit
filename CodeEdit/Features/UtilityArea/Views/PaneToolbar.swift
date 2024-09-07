//
//  PaneToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/31/23.
//

import SwiftUI

struct PaneToolbar<Content: View>: View {
    @ViewBuilder var content: Content
    @EnvironmentObject var model: UtilityAreaTabViewModel
    @Environment(\.paneArea)
    var paneArea: PaneArea?

    var body: some View {
        HStack(spacing: 5) {
            if model.hasLeadingSidebar
                && (
                    ((paneArea == .main || paneArea == .mainLeading)
                        && model.leadingSidebarIsCollapsed)
                    || paneArea == .leading
                ) {
                PaneToolbarSection {
                    Spacer()
                        .frame(width: 24)
                }
                .opacity(0)
            }
            content
            if model.hasTrailingSidebar
                && (
                    ((paneArea == .main || paneArea == .mainTrailing)
                        && model.trailingSidebarIsCollapsed)
                    || paneArea == .trailing
                ) || !model.hasTrailingSidebar {
                if model.hasTrailingSidebar {
                    PaneToolbarSection {
                        Spacer()
                            .frame(width: 24)
                    }
                    .opacity(0)
                }
            }
        }
        .buttonStyle(.icon(size: 24))
        .padding(.horizontal, 5)
        .padding(.vertical, 8)
        .frame(maxHeight: 27)
    }
}
