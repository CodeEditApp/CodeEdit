//
//  CodeEditContainer.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 08.04.26.
//

import CodeEditCore
import Factory

extension Container {
    var lspService: Factory<LSPService> {
        self { @MainActor in LSPService() }.singleton
    }

    var workspaceWindowManager: Factory<WorkspaceWindowManager> {
        self { @MainActor in WorkspaceWindowManager() }.singleton
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

    var notificationManager: Factory<NotificationManaging> {
        self { NotificationManager() as NotificationManaging }.singleton
    }

    var registryManager: Factory<RegistryManager> {
        self { @MainActor in RegistryManager() }.singleton
    }

    var eventBus: Factory<EventBus> {
        self { EventBus() }.singleton
    }
}
