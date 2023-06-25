//
//  SymLink.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

class SymLink: Resource {
    var url: URL
    var name: String
    var contentType: UTType

    weak var parentFolder: Folder?

    var systemImage: String = "link"

    init(url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey, .contentTypeKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
        self.contentType = values.contentType!
    }

    var id: UInt64

    func fileName(typeHidden: Bool) -> String {
        name
    }

    var iconColor: Color = .accentColor

    func update(with url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey, .contentTypeKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
        self.contentType = values.contentType!
    }

    func resolveItem(components: [String]) -> any Resource {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}
