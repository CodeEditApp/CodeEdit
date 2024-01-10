//
//  NavigatorAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorAreaView: View {
    @ObservedObject private var workspace: WorkspaceDocument
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: NavigatorSidebarViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    init(workspace: WorkspaceDocument, viewModel: NavigatorSidebarViewModel) {
        self.workspace = workspace
        self.viewModel = viewModel

        viewModel.tabItems = [.project, .sourceControl, .search] +
        extensionManager
            .extensions
            .map { ext in
                ext.availableFeatures.compactMap {
                    if case .sidebarItem(let data) = $0, data.kind == .navigator {
                        return NavigatorTab.uiExtension(endpoint: ext.endpoint, data: data)
                    }
                    return nil
                }
            }
            .joined()
    }

    var sidebarPositionEdge: Edge {
        switch sidebarPosition {
        case .top:
            return .top
        case .side:
            return .leading
        }
    }

    var body: some View {
        Group {
            if viewModel.tabItems.isEmpty {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: .zero) {
                    Divider()
                    ReorderableTabView(selection: $viewModel.selectedTab, tabPosition: sidebarPositionEdge) {
                        ForEach(viewModel.tabItems) { item in
                            item
                                .tabTitle(item.title)
                                .tabIcon(item.icon)
                                .tag(item)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        .onInsert(of: [.text], perform: insert)
                    }
                }
            }
        }
        .environmentObject(workspace)
    }

    func move(from indices: IndexSet, to index: Int) {
        viewModel.tabItems.move(fromOffsets: indices, toOffset: index)
    }

    func delete(indices: IndexSet) {
        withAnimation(.spring) {
            viewModel.tabItems.remove(atOffsets: indices)
        }
    }

    func insert(index: Int, items: [NSItemProvider]) {
        Task {
            let newItems = await items.concurrentCompactMap { item in
                try? await withCheckedThrowingContinuation { continuation in
                    _ = item.loadTransferable(type: NavigatorTab.self) { result in
                        continuation.resume(with: result)
                    }
                }
            }
            withAnimation(.spring) {
                viewModel.tabItems.insert(contentsOf: newItems, at: index)
            }
        }
    }
}
