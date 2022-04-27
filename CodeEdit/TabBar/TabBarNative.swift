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

struct TabBarNativeInactiveBackground: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    var body: some View {
        ZStack(alignment: .top) {
            TabBarNativeInactiveBackgroundColor()
            // When tab bar style is `native`, we put the top divider beneath tabs.
            TabBarTopDivider()
        }
    }
}

struct TabBarNativeInactiveBackgroundColor: View {
    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        Color(nsColor: .black)
            .opacity(colorScheme == .dark ? 0.45 : 0.05)
    }
}

struct TabBarNativeMaterial: View {
    var body: some View {
        EffectView(
            NSVisualEffectView.Material.titlebar,
            blendingMode: NSVisualEffectView.BlendingMode.withinWindow
        )
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
