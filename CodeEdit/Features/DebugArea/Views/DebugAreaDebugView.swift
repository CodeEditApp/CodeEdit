//
//  DebugAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct DebugAreaDebugView: View {
    @State var sidebarIsCollapsed = false
    @State var tabSelection = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            SplitView(axis: .horizontal) {
                List(selection: $tabSelection) {
                    EmptyView()
                }
                .listStyle(.automatic)
                .accentColor(.secondary)
                .collapsable()
                .collapsed($sidebarIsCollapsed)
                .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    HStack(spacing: 0) {
//                        Button {
//                            // add
//                        } label: {
//                            Image(systemName: "plus")
//                        }
//                        .buttonStyle(.icon(size: 29))
//                        Button {
//                            // remove
//                        } label: {
//                            Image(systemName: "minus")
//                        }
//                        .buttonStyle(.icon(size: 29))
                    }
                    .padding(.leading, 29)
                }
                VStack(spacing: 0) {
                    Text("Nothing to debug")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .holdingPriority(.init(1))
            }
            HStack(spacing: 0) {
                Button {
                    sidebarIsCollapsed.toggle()
                } label: {
                    Image(systemName: "square.leadingthird.inset.filled")
                }
                .buttonStyle(.icon(isActive: !sidebarIsCollapsed, size: 29))
                Divider()
                    .frame(height: 12)
                Spacer()
            }
        }
    }
}
