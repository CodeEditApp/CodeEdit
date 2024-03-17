//
//  View+HideSidebarToggle.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/5/23.
//

import SwiftUI

extension View {
    func hideSidebarToggle() -> some View {
        modifier(HideSidebarToggleViewModifier())
    }
}

struct HideSidebarToggleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task {
                let window = NSApp.windows.first { $0.identifier?.rawValue == SceneID.settings.rawValue }!
                let sidebaritem = "com.apple.SwiftUI.navigationSplitView.toggleSidebar"
                let index = window.toolbar?.items.firstIndex { $0.itemIdentifier.rawValue == sidebaritem }
                if let index {
                    window.toolbar?.removeItem(at: index)
                }
            }
    }
}
