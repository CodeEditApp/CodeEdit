//
//  KeyboardShortcutWrapper.swift
//  CodeEditSettings
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import SwiftUI

/// Wrapper for KeyboardShortcut. It contains name, keybindings.
public struct KeyboardShortcutWrapper: Codable, Hashable {
    public var keyboardShortcut: KeyboardShortcut {
        return KeyboardShortcut.init(.init(Character(keybinding)), modifiers: parsedModifier)
    }

    public var parsedModifier: EventModifiers {
        switch modifier {
        case "command":
            return EventModifiers.command
        case "shift":
            return EventModifiers.shift
        case "option":
            return EventModifiers.option
        case "control":
            return EventModifiers.control
        default:
            return EventModifiers.command
        }
    }
    public var name: String
    public var description: String
    public var context: String
    public var keybinding: String
    public var modifier: String
    public var id: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case context
        case keybinding
        case modifier
        case id
    }

    public init(name: String, description: String, context: String, keybinding: String, modifier: String, id: String) {
        self.name = name
        self.description = description
        self.context = context
        self.keybinding = keybinding
        self.modifier = modifier
        self.id = id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        context = try container.decode(String.self, forKey: .context)
        keybinding = try container.decode(String.self, forKey: .keybinding)
        modifier = try container.decode(String.self, forKey: .modifier)
        id = try container.decode(String.self, forKey: .id)
    }
}
