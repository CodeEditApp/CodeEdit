//
//  CodeEditContainer.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 08.04.26.
//

import CodeEditCore
import CodeEditDocument
import ShellClient
import Factory

extension Container {
    var lspService: Factory<LSPService> {
        self { @MainActor in
            LSPService(notificationManager: AppDependencies.bridgeShared.notificationManager)
        }.singleton
    }

    var workspaceWindowManager: Factory<WorkspaceWindowManager> {
        self { @MainActor in WorkspaceWindowManager(dependencies: AppDependencies.bridgeShared) }.singleton
    }

    var shellClient: Factory<ShellClientProtocol> {
        self { ShellClient() as ShellClientProtocol }.singleton
    }

    var commandManager: Factory<CommandManaging> {
        self { CommandManager() as CommandManaging }.singleton
    }

    var keybindingManager: Factory<KeybindingManaging> {
        self { KeybindingManager() as KeybindingManaging }.singleton
    }

    var registryManager: Factory<RegistryManager> {
        self { @MainActor in
            RegistryManager(
                eventBus: AppDependencies.bridgeShared.eventBus,
                notificationManager: AppDependencies.bridgeShared.notificationManager
            )
        }.singleton
    }
}
