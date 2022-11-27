//
//  PanelDivider.swift
//  
//
//  Created by Austin Condiff on 5/10/22.
//

import SwiftUI

struct PanelDivider: View {
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        Divider()
            .opacity(0)
            .overlay(
                Color(.black)
                    .opacity(colorScheme == .dark ? 0.65 : 0.13)
            )
    }
}
