//
//  WindowObserver.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

struct WindowObserver<Content: View>: View {

    var window: WindowBox

    @ViewBuilder var content: Content

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State private var isFullscreen = false

    @State var modifierFlags: NSEvent.ModifierFlags = []

    var body: some View {
        content
            .environment(\.modifierKeys, modifierFlags.intersection(.deviceIndependentFlagsMask))
            .onReceive(NSEvent.publisher(scope: .local, matching: .flagsChanged)) { output in
                modifierFlags = output.modifierFlags
            }
            .environment(\.window, window)
            .environment(\.isFullscreen, isFullscreen)
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
                self.isFullscreen = true
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
                self.isFullscreen = false
            }
    }
}
