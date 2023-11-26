//
//  UtilityAreaTabView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/30/23.
//

import SwiftUI

struct UtilityAreaTabView<Content: View, LeadingSidebar: View, TrailingSidebar: View>: View {
    @ObservedObject var model: UtilityAreaTabViewModel

    let content: (UtilityAreaTabViewModel) -> Content
    let leadingSidebar: (UtilityAreaTabViewModel) -> LeadingSidebar?
    let trailingSidebar: (UtilityAreaTabViewModel) -> TrailingSidebar?

    let hasLeadingSidebar: Bool
    let hasTrailingSidebar: Bool

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder leadingSidebar: @escaping (UtilityAreaTabViewModel) -> LeadingSidebar,
        @ViewBuilder trailingSidebar: @escaping (UtilityAreaTabViewModel) -> TrailingSidebar,
        hasLeadingSidebar: Bool = true,
        hasTrailingSidebar: Bool = true
    ) {
        self.model = model

        self.content = content
        self.leadingSidebar = leadingSidebar
        self.trailingSidebar = trailingSidebar

        self.hasLeadingSidebar = hasLeadingSidebar
        self.hasTrailingSidebar = hasTrailingSidebar
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content
    ) where
        LeadingSidebar == EmptyView,
        TrailingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: { _ in EmptyView() },
            trailingSidebar: { _ in EmptyView() },
            hasLeadingSidebar: false,
            hasTrailingSidebar: false
        )
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder leadingSidebar: @escaping (UtilityAreaTabViewModel) -> LeadingSidebar
    ) where TrailingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: leadingSidebar,
            trailingSidebar: { _ in EmptyView() },
            hasTrailingSidebar: false
        )
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder trailingSidebar: @escaping (UtilityAreaTabViewModel) -> TrailingSidebar
    ) where LeadingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: { _ in EmptyView() },
            trailingSidebar: trailingSidebar,
            hasLeadingSidebar: false
        )
    }

    var body: some View {
        SplitView(axis: .horizontal) {
            // Leading Sidebar
            if model.hasLeadingSidebar {
                leadingSidebar(model)
                    .collapsable()
                    .collapsed($model.leadingSidebarIsCollapsed)
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                    .environment(\.paneArea, .leading)
            }

            // Content Area
            content(model)
                .holdingPriority(.init(1))
                .environment(\.paneArea, .main)

            // Trailing Sidebar
            if model.hasTrailingSidebar {
                trailingSidebar(model)
                    .collapsable()
                    .collapsed($model.trailingSidebarIsCollapsed)
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                    .environment(\.paneArea, .trailing)
            }
        }
        .animation(.default, value: model.leadingSidebarIsCollapsed)
        .animation(.default, value: model.trailingSidebarIsCollapsed)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) {
            if model.hasLeadingSidebar {
                PaneToolbar {
                    PaneToolbarSection {
                        Button {
                            model.leadingSidebarIsCollapsed.toggle()
                        } label: {
                            Image(systemName: "square.leadingthird.inset.filled")
                        }
                        .buttonStyle(.icon(isActive: !model.leadingSidebarIsCollapsed))
                    }
                    Divider()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if model.hasTrailingSidebar {
                PaneToolbar {
                    Divider()
                    PaneToolbarSection {
                        Button {
                            model.trailingSidebarIsCollapsed.toggle()
                        } label: {
                            Image(systemName: "square.trailingthird.inset.filled")
                        }
                        .buttonStyle(.icon(isActive: !model.trailingSidebarIsCollapsed))
                        Spacer()
                            .frame(width: 24)
                    }
                }
            }
        }
        .environmentObject(model)
        .onAppear {
            model.hasLeadingSidebar = hasLeadingSidebar
            model.hasTrailingSidebar = hasTrailingSidebar
        }
    }
}

enum PaneArea: String {
    case leading
    case main
    case mainLeading
    case mainCenter
    case mainTrailing
    case trailing
}

private struct PaneAreaKey: EnvironmentKey {
    static let defaultValue: PaneArea? = nil
}

extension EnvironmentValues {
    var paneArea: PaneArea? {
        get { self[PaneAreaKey.self] }
        set { self[PaneAreaKey.self] = newValue }
    }
}

struct PaneToolbarSection<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 0) {
            content
        }
    }
}
