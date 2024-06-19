//
//  EditorTabBarDivider.swift
//  CodeEdit
//
//  Created by Lingxi Li on 4/22/22.
//

import SwiftUI

/// The vertical divider between tab bar items.
struct EditorTabDivider: View {
    @Environment(\.colorScheme)
    var colorScheme

    let width: CGFloat = 1

    var body: some View {
        Rectangle()
            .frame(width: width)
            .padding(.vertical, 8)
            .foregroundColor(
                Color(nsColor: colorScheme == .dark ? .white : .black)
                    .opacity(0.12)
            )
    }
}
