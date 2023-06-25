//
//  SymLink.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI

class SymLink: Resource {
    var url: URL
    var name: String

    weak var parentFolder: Folder?

    var systemImage: String = "link"

    init(url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
    }

    var id: UInt64

    func fileName(typeHidden: Bool) -> String {
        name
    }

    var iconColor: Color = .accentColor

    func update(with url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
    }

    func resolveItem(components: [String]) -> any Resource {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}
