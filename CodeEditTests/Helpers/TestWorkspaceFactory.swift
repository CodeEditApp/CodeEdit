//
//  TestWorkspaceFactory.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Foundation
@testable import CodeEdit

/// Builds a real `Workspace` via `WorkspaceFactory.make` on a fresh temp directory.
/// `AppDependencies` is all-lazy, so a per-test instance is cheap.
@MainActor
enum TestWorkspaceFactory {
    static func make(dependencies: AppDependencies? = nil) throws -> Workspace {
        let dependencies = dependencies ?? AppDependencies()
        let dir = URL(filePath: NSTemporaryDirectory())
            .appending(path: "workspace-tests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return WorkspaceFactory.make(url: dir, dependencies: dependencies)
    }
}
