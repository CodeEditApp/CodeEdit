//
//  Environment+AppCommands.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI
import CodeEditCore

private struct FileRelocatorKey: EnvironmentKey {
    static let defaultValue: FileRelocator = NoOpFileRelocator()
}

extension EnvironmentValues {
    /// The command used to move/rename a file within its owning workspace.
    /// No-op by default (previews, tests); injected at the workspace window's root.
    var fileRelocator: FileRelocator {
        get { self[FileRelocatorKey.self] }
        set { self[FileRelocatorKey.self] = newValue }
    }
}
