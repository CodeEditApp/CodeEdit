//
//  WindowObserver.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

struct WindowObserver<Content: View>: View {

    var window: NSWindow

    @ViewBuilder
    var content: Content

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State
    private var isFullscreen = false

    @StateObject
    private var prefs: SettingsModel = .shared

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
            // When tab bar style is changed, update NSWindow configuration as follows.
            .onChange(of: prefs.settings.general.tabBarStyle) { newStyle in
                DispatchQueue.main.async {
                    if newStyle == .native {
                        window.titlebarSeparatorStyle = .none
                    } else {
                        window.titlebarSeparatorStyle = .automatic
                    }
                }
            }
    }
}
