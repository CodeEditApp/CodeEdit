//
//  View+paneToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/31/23.
//

import SwiftUI

extension View {
    /// Clips and adds a bottom toolbar to the view.
    /// - Parameter content: The content of the toolbar.
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
