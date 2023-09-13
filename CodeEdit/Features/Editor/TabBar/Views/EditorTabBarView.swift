//
//  EditorTabBarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol and Lingxi Li on 17.03.22.
//

import SwiftUI

struct EditorTabBarView: View {
    /// The height of tab bar.
    /// I am not making it a private variable because it may need to be used in outside views.
    static let height = 28.0

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            EditorTabBarLeadingAccessories()
            EditorTabs()
            EditorTabBarTrailingAccessories()
        }
        .frame(height: EditorTabBarView.height)
        .overlay(alignment: .top) {
            // When tab bar style is `xcode`, we put the top divider as an overlay.
            if tabBarStyle == .xcode {
                EditorTabBarTopDivider()
            }
        }
        .background {
            if tabBarStyle == .native {
                EditorTabBarNativeMaterial()
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .padding(.leading, -1)
    }
}
