//
//  WorkspaceTabGroupView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct WorkspaceTabGroupView: View {
    @ObservedObject var tabgroup: TabGroupData

    @EnvironmentObject var workspace: WorkspaceDocument

    @FocusState var isFocused

    var body: some View {
        VStack {
            if let selected = tabgroup.selected {
                WorkspaceCodeFileView(file: selected)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += TabBarView.height + BreadcrumbsView.height + 1 + 1
                    }
            } else {
                VStack {
                    Spacer()
                    Text("No Editor")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBarView()
                    .id("TabBarView" + tabgroup.id.uuidString)
                    .environmentObject(tabgroup)
                    .environment(\.controlActiveState, tabgroup == workspace.activeTab ? .key : .inactive)

                Divider()
                if let file = tabgroup.selected {
                    BreadcrumbsView(file: file) { newFile in
                        print("Opening \(newFile.fileName)")
                        let index = tabgroup.files.firstIndex(of: file)
                        if let index {
                            tabgroup.files.insert(file, at: index)
//                            DispatchQueue.main.async {
                                tabgroup.files.remove(file)
//                            }
                            tabgroup.selected = file
                        }
                    }
                    Divider()
                }
            }
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .focused($isFocused)
        .onChange(of: isFocused) { focused in
            if focused {
                workspace.activeTab = tabgroup
            }
        }
    }
}
