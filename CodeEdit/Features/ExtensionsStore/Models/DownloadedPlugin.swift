//
//  DownloadedPlugin.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 6.04.22.
//

import Foundation
import GRDB

struct DownloadedPlugin: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static var databaseTableName = "downloadedplugin"

    var id: Int64?
    var plugin: UUID
    var release: UUID
    var loadable: Bool
    var sdk: Plugin.SDK
}
