//
//  Environment+IsFullscreen.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    /// Whether the window hosting this view is in fullscreen, so views can adapt their layout (e.g. the
    /// toolbar inset).
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
