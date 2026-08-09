//
//  LanguageServerSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

public struct LanguageServerSettings: Codable, Hashable {

    /// Stores the currently installed language servers. The key is the name of the language server.
    @CodableDefault<DefaultEmptyLanguageServerDictionary> public var installedLanguageServers:
        [String: Installed] = [:]

    /// Default initializer
    public init() {}

    public struct Installed: Codable, Hashable {
        public let packageName: String
        public var isEnabled: Bool
        public let version: String

        public init(packageName: String, isEnabled: Bool, version: String) {
            self.packageName = packageName
            self.isEnabled = isEnabled
            self.version = version
        }
    }
}
