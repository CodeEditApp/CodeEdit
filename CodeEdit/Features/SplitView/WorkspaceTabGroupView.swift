//
//  WorkspaceTabGroupView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct WorkspaceTabGroupView: View {
    @ObservedObject var tabgroup: TabGroupData

    @Environment(\.window) var window

    var toolbarHeight: CGFloat {
        window.contentView?.safeAreaInsets.top ?? .zero
    }

    var edgeInsets: NSEdgeInsets {
        .init(top: toolbarHeight + TabBarView.height + BreadcrumbsView.height + 1 + 1, leading: 0, bottom: 0, trailing: 0)
    }

    var body: some View {
        VStack {
            if let selected = tabgroup.selected {
                WorkspaceCodeFileView(file: selected)
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
        .environment(\.edgeInsets, edgeInsets)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBarView()
                    .environmentObject(tabgroup)

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
    }
}
