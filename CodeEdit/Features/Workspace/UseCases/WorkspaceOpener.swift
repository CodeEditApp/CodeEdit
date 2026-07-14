//
//  WorkspaceOpener.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import AppKit

/// Creates and configures a workspace, window, and window controller for a given URL.
@MainActor
final class WorkspaceOpener {
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    struct Result {
        let workspace: Workspace
        let window: NSWindow
        let windowController: CodeEditWindowController
    }

    func execute(url: URL) -> Result {
        let workspace = WorkspaceFactory.make(url: url, dependencies: dependencies)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let windowController = CodeEditWindowController(
            window: window,
            workspace: workspace,
            dependencies: dependencies
        )

        // Restore saved window geometry, or use default centered frame
        if let rectString = workspace.statePersistence.get(.workspaceWindowSize) as? String {
            window.setFrame(NSRectFromString(rectString), display: true, animate: false)
        } else {
            window.setFrame(NSRect(x: 0, y: 0, width: 1400, height: 900), display: true, animate: false)
            window.center()
        }

        window.setAccessibilityIdentifier("workspace")
        window.setAccessibilityDocument(workspace.fileURL.absoluteString)

        return Result(workspace: workspace, window: window, windowController: windowController)
    }
}
