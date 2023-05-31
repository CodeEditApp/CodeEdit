//
//  DebugAreaView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct DebugAreaView: View {
    @EnvironmentObject
    private var model: DebugAreaViewModel

    private var items: [DebugAreaTab] {
        [.terminal, .debug, .output]
    }

    @State
    private var selection: DebugAreaTab.ID = DebugAreaTab.terminal.id

    var body: some View {
        VStack(spacing: 0) {
            switch items.first(where: { $0.id == selection }) {
            case .terminal:
                DebugAreaTerminalView()
            case .debug:
                DebugAreaDebugView()
            case .output:
                DebugAreaOutputView()
            default:
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            DebugAreaTabBar(items: items, selection: $selection, position: .side)
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
}
