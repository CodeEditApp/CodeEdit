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

struct TabBarNativeBackgroundInactive: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    var body: some View {
        ZStack(alignment: .top) {
            TabBarNativeBackgroundInactiveColor()
            // When tab bar style is `native`, we put the top divider beneath tabs.
            TabBarTopDivider()
        }
    }
}

struct TabBarNativeBackgroundInactiveColor: View {
    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        Color(nsColor: .black)
            .opacity(colorScheme == .dark ? 0.45 : 0.05)
    }
}
