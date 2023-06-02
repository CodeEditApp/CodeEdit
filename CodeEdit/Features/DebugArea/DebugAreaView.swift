//
//  DebugAreaView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct AreaTab: Identifiable, Equatable {
    var id: String
    var title: String
    var systemImage: String? = "e.square"
    var contentView: () -> AnyView

    init<Content: View>(id: String, title: String, systemImage: String? = "e.square", @ViewBuilder content: @escaping () -> Content) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.contentView = { AnyView(content()) }
    }

    static func == (lhs: AreaTab, rhs: AreaTab) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.systemImage == rhs.systemImage
    }
}

struct DebugAreaView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var model: DebugAreaViewModel

    @State var selection: AreaTab?

    private var items: [AreaTab] {
        [
            .init(id: "terminal", title: "Terminal", systemImage: "terminal") {
                DebugAreaTerminalView()
            },
            .init(id: "debug.console", title: "Debug Console", systemImage: "ladybug") {
                DebugAreaDebugView()
            },
            .init(id: "output", title: "Output", systemImage: "list.bullet.indent") {
                DebugAreaOutputView()
            },
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            if selection != nil {
                selection!.contentView()
            } else {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AreaTabBar(items: items, selection: $selection, position: .side)
                Divider()
                    .overlay(Color(nsColor: colorScheme == .dark ? .black : .clear))
            }
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
        .onAppear {
            selection = items.first!
        }
    }
}
