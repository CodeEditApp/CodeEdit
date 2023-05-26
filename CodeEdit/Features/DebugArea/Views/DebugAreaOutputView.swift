//
//  DebugAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct DebugAreaOutputView: View {
    @EnvironmentObject
    private var model: StatusBarViewModel
    
    @State
    private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            Text("No output")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(alignment: .center, spacing: 6.5) {
                Spacer()
                FilterTextField(title: "Filter", text: $searchText)
                    .frame(maxWidth: 175)
                    .padding(.leading, -2)
                Button {
                    // clear logs
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.icon)
                Divider()
                HStack(alignment: .center, spacing: 3.5) {
                    Button {
                        // split terminal
                    } label: {
                        Image(systemName: "square.split.2x1")
                    }
                    .buttonStyle(.icon)
                    Button {
                        model.isMaximized.toggle()
                    } label: {
                        Image(systemName: "arrowtriangle.up.square")
                    }
                    .buttonStyle(.icon(isActive: model.isMaximized))
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 8)
//            .padding(.leading, model.debuggerSidebarIsCollapsed ? 29 : 0)
//            .animation(.default, value: model.debuggerSidebarIsCollapsed)
            .frame(maxHeight: 28)
        }
    }
}
