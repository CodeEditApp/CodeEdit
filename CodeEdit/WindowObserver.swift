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
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        content
            .environment(\.window, window)
            .environment(\.isFullscreen, isFullscreen)
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
                self.isFullscreen = true
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
                self.isFullscreen = false
            }
            // When tab bar style is changed, update NSWindow configuration as follows.
            .onChange(of: prefs.preferences.general.tabBarStyle) { newStyle in
                DispatchQueue.main.async {
                    if newStyle == .native {
                        window.titlebarAppearsTransparent = true
                        window.titlebarSeparatorStyle = .none
                    } else {
                        window.titlebarAppearsTransparent = false
                        window.titlebarSeparatorStyle = .automatic
                    }
                }
            }
    }
}
