//
//  TabBarNative.swift
//  CodeEdit
//
//  This file contains some support views to make native tab bar style come true.
//
//  Created by Lingxi Li on 4/25/22.
//

import SwiftUI
import AppPreferences
import WorkspaceClient
import CodeEditUI

/// Native style background view (including color and shadow divider) for tab bar.
struct TabBarNativeInactiveBackground: View {
    var body: some View {
        ZStack(alignment: .top) {
            TabBarNativeInactiveBackgroundColor()
            // When tab bar style is `native`, we put the top divider beneath tabs.
            TabBarTopDivider()
        }
    }
}

/// Native style background color for tab bar.
struct TabBarNativeInactiveBackgroundColor: View {
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        Color(nsColor: .black)
            .opacity(colorScheme == .dark ? 0.45 : 0.05)
    }
}

/// Native style background material for tab bar.
struct TabBarNativeMaterial: View {
    var body: some View {
        EffectView(
            NSVisualEffectView.Material.titlebar,
            blendingMode: NSVisualEffectView.BlendingMode.withinWindow
        )
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
