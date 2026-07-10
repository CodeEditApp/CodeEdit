//
//  AppDependencies.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import CodeEditCore
import CodeEditDocument
import Factory
import Notifications
import ShellClient

/// The app-scope composition root. Owns every process-lifetime service.
///
/// Transitional note: during the strangler-bridge migration, properties are
/// initialized FROM `Container.shared` so both worlds share instances. The
/// final migration task replaces these reads with direct construction and
/// deletes the container.
///
/// Properties are `lazy` to preserve the resolution timing of the
/// `@LazyInjected` sites they replace (e.g. `RegistryManager` performs I/O on
/// first touch) and to allow adapters to reference sibling properties.
@MainActor
final class AppDependencies {
    /// Bridge-phase backdoor so the container registration can construct the
    /// window manager without creating a second dependency graph. AppDelegate
    /// assigns this before anything resolves the key. Deleted with the container.
    nonisolated(unsafe) static var bridgeShared: AppDependencies!

    private(set) lazy var eventBus: EventBus = Container.shared.eventBus()
    private(set) lazy var shellClient: ShellClientProtocol = Container.shared.shellClient()
    private(set) lazy var commandManager: CommandManaging = Container.shared.commandManager()
    private(set) lazy var keybindingManager: KeybindingManaging = Container.shared.keybindingManager()
    private(set) lazy var notificationManager: NotificationManaging = Container.shared.notificationManager()
    private(set) lazy var lspService: LSPService = Container.shared.lspService()
    private(set) lazy var registryManager: RegistryManager = Container.shared.registryManager()
    private(set) lazy var workspaceWindowManager: WorkspaceWindowManager = Container.shared.workspaceWindowManager()
}
