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

    @State var selection: UtilityAreaTab? = .terminal

    var body: some View {
//        BasicTabView(selection: $selection, tabPosition: .side) {
//            ForEach(UtilityAreaTab.allCases) {
//                $0
//                    .tabIcon(Image(systemName: $0.systemImage))
//                    .tabTitle($0.title)
//            }
//            .onMove { _, _ in
//                
//            }
//        }
//        .onMoveTab { _, _ in
//            
//        }
        VStack{}
//        VStack(spacing: 0) {
//            if let selection {
//                selection
//            } else {
//                Text("Tab not found")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AreaTabBar(items: $model.tabItems, selection: $selection, position: .side)
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
    }
}
