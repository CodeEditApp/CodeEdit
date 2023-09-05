//
//  View+paneToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/31/23.
//

import SwiftUI

extension View {
    func paneToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        self
            .clipped()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PaneToolbar {
                    content()
                }
            }
    }
}
