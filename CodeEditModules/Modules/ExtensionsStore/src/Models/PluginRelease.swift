//
//  PluginRelease.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

public struct PluginRelease: Codable, Hashable, Identifiable {
    public var id: UUID
    public var externalID: String
    public var version: String
    public var tarball: URL?
}
