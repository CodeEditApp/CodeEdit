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

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            EditorTabBarLeadingAccessories()
            EditorTabs()
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Tab Bar")
                .accessibilityIdentifier("TabBar")
            EditorTabBarTrailingAccessories()
        }
        .frame(height: EditorTabBarView.height)
        .padding(.leading, -1)
    }
}
