//
//  WelcomeWindowRequestedEvent.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 01.07.26.
//

/// Published by `WorkspaceWindowManager` when the last workspace closes
/// and the user preference is set to show the welcome window.
///
/// Consumed by `AppDelegate`, which holds the SwiftUI `openWindow` environment action.
public struct WelcomeWindowRequestedEvent: Event {
    public init() {}
}
