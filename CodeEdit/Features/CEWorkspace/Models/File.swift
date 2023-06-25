//
//  File.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

class File: Resource, Identifiable, Hashable {
    var id: UInt64
    var url: URL
    var name: String
    var displayName: String
    var fileType: FileIcon.FileType?

    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

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
        (self.name, self.id, self.displayName, self.fileType) = try Self.update(with: url)
    }

    // swiftlint:disable large_tuple
    fileprivate static func update(with url: URL) throws -> (String, UInt64, String, FileIcon.FileType?) {
        let values = try url.resourceValues(forKeys: [.nameKey, .fileIdentifierKey])
        let name = values.name!
        let id = values.fileIdentifier!
        let displayName = name.split(separator: ".").dropLast().joined(separator: ".")

        var fileType: FileIcon.FileType?
        if let last = name.split(separator: ".").last {
            fileType = FileIcon.FileType.init(rawValue: String(last))
        }

        return (name, id, displayName, fileType)
    }
    // swiftlint:enable large_tuple

    var type: FileIcon.FileType { .init(rawValue: url.pathExtension) ?? .txt }

    weak var parentFolder: Folder?

    var document: CodeFileDocument?

    func loadDocument() throws {
        document = try CodeFileDocument(
            for: url,
            withContentsOf: url,
            ofType: UTType.text.identifier
        )
    }

    init(url: URL, name: String) throws {
        self.url = url
        (self.name, self.id, self.displayName, self.fileType) = try Self.update(with: url)
    }

    func resolveItem(components: [String]) -> any Resource {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }

    func labelFileName() -> String {
        let prefs = Settings.shared.preferences.general
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return self.fileName(typeHidden: true)
        case .showAll:
            return self.fileName(typeHidden: false)
        case .showOnly:
            return self.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(self.fileType?.rawValue ?? FileIcon.FileType.txt.rawValue))
        case .hideOnly:
            return self.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(self.fileType?.rawValue ?? FileIcon.FileType.txt.rawValue))
        }
    }
}
