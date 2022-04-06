//
//  DownloadedPlugin.swift
//  
//
//  Created by Pavel Kasila on 6.04.22.
//

import Foundation
import GRDB

public struct DownloadedPlugin: Codable, FetchableRecord, PersistableRecord {
    public var id: Int64?
    public var plugin: UUID
    public var release: UUID
}
