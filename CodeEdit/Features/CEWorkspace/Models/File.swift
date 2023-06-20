//
//  File.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI

class File: ResourceData {

    var url: URL
    var name: String
    var displayName: String
    var fileType: FileIcon.FileType?

    var iconColor: Color {
        guard let fileType else { return .accentColor }
        return FileIcon.iconColor(fileType: fileType)
    }

    var systemImage: String {
        FileIcon.fileIcon(fileType: fileType ?? .txt)
    }

    func fileName(typeHidden: Bool) -> String {
        typeHidden ? displayName : name
    }

    func update(with url: URL) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey])
        self.name = values.name!
        self.displayName = self.name.split(separator: ".").dropLast().joined(separator: ".")

        if let last = self.name.split(separator: ".").last {
            self.fileType = FileIcon.FileType.init(rawValue: String(last))
        }
    }

    var type: FileIcon.FileType { .init(rawValue: url.pathExtension) ?? .txt }

    weak var parentFolder: Folder?

    var document: CodeFileDocument?

    init(url: URL, name: String) throws {
        self.url = url
        let values = try url.resourceValues(forKeys: [.nameKey])
        self.name = values.name!
        self.displayName = self.name.split(separator: ".").dropLast().joined(separator: ".")

        if let last = self.name.split(separator: ".").last {
            self.fileType = FileIcon.FileType.init(rawValue: String(last))
        }
    }

    func resolveItem(components: [String]) -> any ResourceData {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}
