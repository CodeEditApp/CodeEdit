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

    private var height: CGFloat? {
        if #available(macOS 26, *) {
            36.0
        } else {
            nil
        }
    }

    private var maxHeight: CGFloat? {
        if #available(macOS 26, *) {
            nil
        } else {
            27.0
        }
    }

    private var padding: CGSize {
        if #available(macOS 26, *) {
            CGSize(width: 5.0, height: 0)
        } else {
            CGSize(width: 5.0, height: 8.0)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if shouldShowLeadingSection() {
                PaneToolbarSection {
                    Spacer()
                        .frame(width: 24)
                }
                .opacity(0)
            }
            content
            if shouldShowTrailingSection() {
                PaneToolbarSection {
                    Spacer()
                        .frame(width: 24)
                }
                .opacity(0)
            }
            if #available(macOS 26, *), isTrailingItem() {
                Spacer().frame(width: 5)
            }
        }
        .buttonStyle(.icon(size: 24))
        .padding(.horizontal, padding.width)
        .padding(.vertical, padding.height)
        .frame(maxHeight: maxHeight)
        .frame(height: height)
    }

    private func shouldShowLeadingSection() -> Bool {
        model.hasLeadingSidebar
        && (
            ((paneArea == .main || paneArea == .mainLeading) && model.leadingSidebarIsCollapsed)
            || paneArea == .leading
        )
    }

    private func shouldShowTrailingSection() -> Bool {
        model.hasTrailingSidebar
        && (
            ((paneArea == .main || paneArea == .mainTrailing) && model.trailingSidebarIsCollapsed)
            || paneArea == .trailing
        )
    }

    private func isTrailingItem() -> Bool {
        paneArea == .trailing
         || (
            (paneArea == .main || paneArea == .mainTrailing)
            && (model.trailingSidebarIsCollapsed || !model.hasTrailingSidebar)
         )
    }
}
