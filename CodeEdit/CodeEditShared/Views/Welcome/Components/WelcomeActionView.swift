//
//  WelcomeActionView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct WelcomeActionView: View {
    var iconName: String
    var title: String
    var action: () -> Void

    init(iconName: String, title: String, action: @escaping () -> Void) {
        self.iconName = iconName
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            HStack(spacing: 7) {
                Image(systemName: iconName)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
            }
        })
        .buttonStyle(WelcomeActionButtonStyle())
    }
}

struct WelcomeActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            #if os(iOS)
            .padding(14)
            .frame(height: 48)
            .frame(maxWidth: 348)
            .background(Color(UIColor.label).opacity(configuration.isPressed ? 0.1 : 0.05))
            #elseif os(macOS)
            .padding(7)
            .frame(height: 36)
            .background(Color(NSColor.labelColor).opacity(configuration.isPressed ? 0.1 : 0.05))
            #endif
            .cornerRadius(8)
    }
}
