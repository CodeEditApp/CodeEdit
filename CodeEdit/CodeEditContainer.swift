//
//  CodeEditContainer.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 08.04.26.
//

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

    var commandManager: Factory<CommandManager> {
        self { CommandManager() }.singleton
    }

    var keybindingManager: Factory<KeybindingManager> {
        self { KeybindingManager() }.singleton
    }

    var notificationManager: Factory<NotificationManager> {
        self { NotificationManager() }.singleton
    }

    var registryManager: Factory<RegistryManager> {
        self { @MainActor in RegistryManager() }.singleton
    }
}
