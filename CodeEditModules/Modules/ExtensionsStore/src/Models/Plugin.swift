//
//  Plugin.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import SwiftUI
import CodeEditKit
import TabBar

public struct Plugin: Codable, Identifiable, Hashable, TabBarItemRepresentable {
    public var tabID: TabBarItemID {
        .extensionInstallation(self.id)
    }

    public var title: String {
        self.manifest.displayName
    }

    public var icon: Image {
        Image(systemName: "puzzlepiece.extension.fill")
    }

    public var iconColor: Color {
        .blue
    }

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
