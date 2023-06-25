//
//  Folder.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

class Folder: Resource {
    var children: [any Resource] = []
    var url: URL
    var id: UInt64
    var contentType: UTType
    var name: String

    var systemImage: String {
        if parentFolder == nil || name == ".codeedit" {
            return "folder.fill.badge.gearshape"
        }
        return children.isEmpty ? "folder" : "folder.fill"
    }

    weak var parentFolder: Folder?

    // TODO: Change this to Color(.folderBlue) once Xcode 15 is released
    var iconColor: Color = Color(nsColor: NSColor(named: "FolderBlue")!)

    init(url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey, .contentTypeKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
        self.contentType = values.contentType!
    }

    func fileName(typeHidden: Bool) -> String {
        name
    }

    func update(with url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey, .contentTypeKey])
        self.name = values.name!
        self.id = values.fileIdentifier!
        self.contentType = values.contentType!
    }

    func resolveItem(components: [String]) -> any Resource {
        if components.isEmpty {
            return self
        }

        let child = children
            .first { $0.name == components.first }

        guard let child else {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
            return self
        }

        return child.resolveItem(components: Array(components.dropFirst()))
    }

    func removeChild(_ child: any Resource) {
        children.removeAll { $0 === child }
    }

    func addChild(_ child: any Resource) {
        children.append(child)
    }
}
