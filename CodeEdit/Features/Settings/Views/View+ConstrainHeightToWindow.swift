//
//  View+ConstrainHeightToWindow.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

extension NSWindow {
    var isSettingsWindow: Bool {
        self.identifier?.rawValue == SceneID.settings.rawValue
    }
}

extension NSApplication {
    var settingsWindow: NSWindow? {
        NSApp.windows.first { $0.isSettingsWindow }
    }
}

extension View {
    func constrainHeightToWindow() -> some View {
        modifier(ConstrainHeightToWindowViewModifier())
    }
}

struct ConstrainHeightToWindowViewModifier: ViewModifier {
    @State var height: CGFloat = 100

    func body(content: Content) -> some View {
        content
            .frame(height: height-100)
            .onReceive(NSApp.settingsWindow!.publisher(for: \.frame)) { newValue in
                height = newValue.height
            }
    }
}
