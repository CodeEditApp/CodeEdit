//
//  Plugin.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import SwiftUI
import CodeEditKit

struct Plugin: Codable, Identifiable, Hashable, TabBarItemRepresentable {
    var tabID: TabBarItemID {
        .extensionInstallation(self.id)
    }

    var title: String {
        self.manifest.displayName
    }

    var icon: Image {
        Image(systemName: "puzzlepiece.extension.fill")
    }

    var iconColor: Color {
        .blue
    }

    var id: UUID
    var manifest: ExtensionManifest
    var author: UUID
    var sdk: SDK
    var management: ReleaseManagement
    var ban: Ban?

    enum SDK: String, Codable, Hashable {
        case swift
        case languageServer = "language_server"
    }

    enum ReleaseManagement: String, Codable, Hashable {
        case githubReleases = "gh_releases"
    }

    struct Ban: Codable, Hashable {
        var bannedBy: UUID
        var reason: String
    }
}
