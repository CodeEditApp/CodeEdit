//
//  View+paneToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/31/23.
//

import SwiftUI

extension View {
    /// Clips and adds a bottom toolbar to the view.
    /// - Parameters:
    ///   - showDivider: True if a divider between the main content and the toolbar should be shown.
    ///   - content: The content of the toolbar.
    func paneToolbar<Content: View>(showDivider: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        self
            .clipped()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    if showDivider {
                        Rectangle()
                            .fill(Color(nsColor: .separatorColor))
                            .frame(height: 1)
                    }
                    PaneToolbar {
                        content()
                    }
                }
            }
    }
}
