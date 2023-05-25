//
//  DebugAreaView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct DebugAreaView: View {
    private var items: [DebugAreaTab] {
        [.terminal, .debug, .output]
    }

    @State
    private var selection: DebugAreaTab.ID = DebugAreaTab.terminal.id

    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            DebugAreaTabBar(items: items, selection: $selection, position: .side)
        }
    }
}
