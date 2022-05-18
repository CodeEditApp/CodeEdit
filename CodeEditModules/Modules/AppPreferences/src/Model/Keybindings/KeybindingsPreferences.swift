//
//  KeybindingsPreferences.swift
//  CodeEditModules/AppPreferences
//  
//  Created by Alex on 18.05.2022.
//

import Foundation
import Keybindings

public extension AppPreferences {

    /// The global settings for text editing
    struct KeybindingsPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var keybindings: [String: KeyboardShortcutWrapper] = .init()

        /// Default initializer
        public init() {
            keybindings = KeybindingManager.shared.keyboardShortcuts
        }

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.keybindings = try container.decodeIfPresent([String: KeyboardShortcutWrapper].self,
                                                                       forKey: .keybindings) ?? .init()
        }
    }

//    struct Keybindings: Codable {
//        /// This id will store the account name as the identifiable
//        public var keybindings: [KeyboardShortcutWrapper] = []
//
//        /// Default initializer
//        public init() {}
//        /// Explicit decoder init for setting default values when key is not present in `JSON`
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.gitAccount = try container.decodeIfPresent([SourceControlAccounts].self, forKey: .gitAccount) ?? []
//            self.sshKey = try container.decodeIfPresent(String.self, forKey: .sshKey) ?? ""
//        }
//    }
}
