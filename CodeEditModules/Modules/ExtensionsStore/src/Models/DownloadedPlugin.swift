//
//  DownloadedPlugin.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 6.04.22.
//

import Foundation
import GRDB

public struct DownloadedPlugin: Codable, FetchableRecord, PersistableRecord, TableRecord {
    public static var databaseTableName = "downloadedplugin"

    public var id: Int64?
    public var plugin: UUID
    public var release: UUID
    public var loadable: Bool
    public var sdk: Plugin.SDK
}
