//
//  PluginRelease.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

struct PluginRelease: Codable, Hashable, Identifiable {
    var id: UUID
    var externalID: String
    var version: String
    var tarball: URL?
}
