//
//  Plugin.swift
//  
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import CEExtensionKit

public struct Plugin: Codable, Identifiable {
    public var id: UUID
    public var manifest: ExtensionManifest
    public var author: UUID
    public var sdk: SDK
    public var management: ReleaseManagement
    public var ban: Ban?

    public enum SDK: String, Codable {
        case swift
    }

    public enum ReleaseManagement: String, Codable {
        case githubReleases = "gh_releases"
    }

    public struct Ban: Codable {
        public var bannedBy: UUID
        public var reason: String
    }
}
