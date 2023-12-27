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
    
    @State var items = [NavigatorTab.project, .search, .sourceControl]
    @State var items2 = [NavigatorTab.project, .search, .sourceControl]
    @State var selection: NavigatorTab = .project
    
    var body: some View {
        Group {
            if items.isEmpty {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: .zero) {
                    Divider()
                    BasicTabView(selection: $viewModel.selectedTab, tabPosition: sidebarPosition) {
                        ForEach(items) { item in
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
        
        //        .safeAreaInset(edge: .leading, spacing: 0) {
        //            if sidebarPosition == .side {
        //                HStack(spacing: 0) {
        //                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
        //                    Divider()
        //                }
        //            }
        //        }
        //        .safeAreaInset(edge: .top, spacing: 0) {
        //            if sidebarPosition == .top {
        //                VStack(spacing: 0) {
        //                    Divider()
        //                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
        //                    Divider()
        //                }
        //            } else {
        //                Divider()
        //            }
        //        }
        .environmentObject(workspace)
    }

    func move(indices: IndexSet, from index: Int) {
        items.move(fromOffsets: indices, toOffset: index)
    }

    func delete(indices: IndexSet) {
        withAnimation(.spring) {
            items.remove(atOffsets: indices)
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
                self.items.insert(contentsOf: newItems, at: index)
            }
        }
    }
}
