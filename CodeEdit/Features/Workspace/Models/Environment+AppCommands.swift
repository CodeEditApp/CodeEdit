//
//  Environment+AppCommands.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI
import CodeEditCore
import CEEditor
import CENotifications
import CESearch
import ShellClient

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

private struct CommandManagerKey: EnvironmentKey {
    static let defaultValue: CommandManaging? = nil
}

private struct ShellClientKey: EnvironmentKey {
    static let defaultValue: ShellClientProtocol? = nil
}

private struct LSPServiceKey: EnvironmentKey {
    static let defaultValue: LSPService? = nil
}

private struct RegistryManagerKey: EnvironmentKey {
    static let defaultValue: RegistryManager? = nil
}

private struct WorkspaceWindowManagerKey: EnvironmentKey {
    static let defaultValue: WorkspaceWindowManager? = nil
}

private struct EventBusKey: EnvironmentKey {
    /// A fresh, isolated bus: previews and tests publish into the void, which is legitimate.
    static let defaultValue: EventBus = EventBus()
}

extension EnvironmentValues {
    /// The command palette registry. Optional: command UI no-ops in previews. Injected by the app shell.
    var commandManager: CommandManaging? {
        get { self[CommandManagerKey.self] }
        set { self[CommandManagerKey.self] = newValue }
    }

    /// The shell client for git and other subprocess work. Optional: git UI without a shell
    /// only occurs in previews. Injected by the app shell.
    var shellClient: ShellClientProtocol? {
        get { self[ShellClientKey.self] }
        set { self[ShellClientKey.self] = newValue }
    }

    /// The LSP service. Optional: language-server UI is empty in previews. Injected by the app shell.
    var lspService: LSPService? {
        get { self[LSPServiceKey.self] }
        set { self[LSPServiceKey.self] = newValue }
    }

    /// The language-server registry. Optional: registry UI is empty in previews. Injected by the app shell.
    var registryManager: RegistryManager? {
        get { self[RegistryManagerKey.self] }
        set { self[RegistryManagerKey.self] = newValue }
    }

    /// The workspace window manager, for flows that open arbitrary files or workspaces
    /// (e.g. Settings pages opening ~/.gitconfig). Optional: nil in previews.
    var workspaceWindowManager: WorkspaceWindowManager? {
        get { self[WorkspaceWindowManagerKey.self] }
        set { self[WorkspaceWindowManagerKey.self] = newValue }
    }

    /// The app-wide event bus. Defaults to an isolated instance so previews publish harmlessly.
    var eventBus: EventBus {
        get { self[EventBusKey.self] }
        set { self[EventBusKey.self] = newValue }
    }
}

extension View {
    /// Injects the app-scope services into this view subtree. Applied at every SwiftUI root:
    /// the app's scenes and each workspace window's split-view content.
    func appServices(_ dependencies: AppDependencies) -> some View {
        environment(\.commandManager, dependencies.commandManager)
            .environment(\.shellClient, dependencies.shellClient)
            .environment(\.lspService, dependencies.lspService)
            .environment(\.registryManager, dependencies.registryManager)
            .environment(\.eventBus, dependencies.eventBus)
            .environment(\.workspaceWindowManager, dependencies.workspaceWindowManager)
            .environment(\.notificationManager, dependencies.notificationManager)
            .environment(\.fileRelocator, dependencies.fileRelocator)
            .environment(\.workspaceFileOpener, dependencies.workspaceFileOpener)
            .environment(\.workspaceNavigator, dependencies.workspaceNavigator)
            .environment(\.languageServices, dependencies.languageServicesProvider)
    }
}

extension Scene {
    /// Scene-level counterpart of `View.appServices(_:)` for the app's scene group.
    func appServices(_ dependencies: AppDependencies) -> some Scene {
        environment(\.commandManager, dependencies.commandManager)
            .environment(\.shellClient, dependencies.shellClient)
            .environment(\.lspService, dependencies.lspService)
            .environment(\.registryManager, dependencies.registryManager)
            .environment(\.eventBus, dependencies.eventBus)
            .environment(\.workspaceWindowManager, dependencies.workspaceWindowManager)
            .environment(\.notificationManager, dependencies.notificationManager)
            .environment(\.fileRelocator, dependencies.fileRelocator)
            .environment(\.workspaceFileOpener, dependencies.workspaceFileOpener)
            .environment(\.workspaceNavigator, dependencies.workspaceNavigator)
            .environment(\.languageServices, dependencies.languageServicesProvider)
    }
}
