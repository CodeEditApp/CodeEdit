//
//  UtilityAreaView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct UtilityAreaView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var model: UtilityAreaViewModel

    @State var selection: UtilityAreaTab = .terminal

    var body: some View {
        ReorderableTabView(selection: $selection, tabPosition: .leading) {
            ForEach(model.tabItems) {
                $0
                    .tabIcon(Image(systemName: $0.systemImage))
                    .tabTitle($0.title)
            }
            .onMove(perform: move)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 5) {
                Divider()
                HStack(spacing: 0) {
                    Button {
                        model.isMaximized.toggle()
                    } label: {
                        Image(systemName: "arrowtriangle.up.square")
                    }
                    .buttonStyle(.icon(isActive: model.isMaximized, size: 24))
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            .frame(maxHeight: 27)
        }
    }

    func move(from indices: IndexSet, to index: Int) {
        model.tabItems.move(fromOffsets: indices, toOffset: index)
    }
}
