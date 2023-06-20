//
//  File.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI

class File: Resource {

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
        (self.name, self.displayName, self.fileType) = try Self.update(with: url)
    }

    // swiftlint:disable large_tuple
    fileprivate static func update(with url: URL) throws -> (String, String, FileIcon.FileType?) {
        let values = try url.resourceValues(forKeys: [.nameKey])
        let name = values.name!
        let displayName = name.split(separator: ".").dropLast().joined(separator: ".")

        var fileType: FileIcon.FileType?
        if let last = name.split(separator: ".").last {
            fileType = FileIcon.FileType.init(rawValue: String(last))
        }

        return (name, displayName, fileType)
    }
    // swiftlint:enable large_tuple

    var type: FileIcon.FileType { .init(rawValue: url.pathExtension) ?? .txt }

    weak var parentFolder: Folder?

    var document: CodeFileDocument?

    init(url: URL, name: String) throws {
        self.url = url
        (self.name, self.displayName, self.fileType) = try Self.update(with: url)
    }

    func resolveItem(components: [String]) -> any Resource {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}
