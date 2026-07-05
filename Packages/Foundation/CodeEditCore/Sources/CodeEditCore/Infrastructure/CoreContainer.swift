//
//  CoreContainer.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Factory

/// Factory keys for Core-owned cross-cutting dependencies.
/// Keys live beside the types they vend; the app shell registers real
/// implementations where a default is not sufficient.
extension Container {
    public var eventBus: Factory<EventBus> {
        self { EventBus() }.singleton
    }

    public var workspaceFileOpener: Factory<WorkspaceFileOpener> {
        self { NoOpWorkspaceFileOpener() }.singleton
    }
}
