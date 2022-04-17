//
//  Plugin.swift
//  
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import CodeEditKit

public struct Plugin: Codable, Identifiable, Hashable {
    public var id: UUID
    public var manifest: ExtensionManifest
    public var author: UUID
    public var sdk: SDK
    public var management: ReleaseManagement
    public var ban: Ban?

    public enum SDK: String, Codable, Hashable {
        case swift
        case languageServer = "language_server"
    }

    public enum ReleaseManagement: String, Codable, Hashable {
        case githubReleases = "gh_releases"
    }

    public struct Ban: Codable, Hashable {
        public var bannedBy: UUID
        public var reason: String
    }
}
