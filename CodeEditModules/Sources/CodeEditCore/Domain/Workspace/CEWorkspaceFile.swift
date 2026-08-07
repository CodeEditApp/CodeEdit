//
//  CEWorkspaceFile.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation
import UniformTypeIdentifiers

/// A file, folder, or symlink in the workspace. This is the UI-free model; presentation,
/// AppKit intents, name-labeling, and editor-document coupling live in app-side extensions.
public final class CEWorkspaceFile: Codable, Comparable, Hashable, Identifiable {

    /// The id of the ``CEWorkspaceFile``.
    public var id: String

    /// Returns the file name (e.g.: `Package.swift`)
    public var name: String { url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Returns the URL of the ``CEWorkspaceFile``
    public let url: URL

    /// Returns the resolved symlink url of this object.
    public lazy var resolvedURL: URL = {
        url.isSymbolicLink ? url.resolvingSymlinksInPath() : url
    }()

    /// Returns a parent ``CEWorkspaceFile``. `nil` for the top-level item.
    public weak var parent: CEWorkspaceFile?

    public var fileIdentifier = UUID().uuidString

    /// The Git status of the file.
    public var gitStatus: GitStatus?

    /// Whether the file is staged for commit.
    public var staged: Bool?

    /// True if the resource is a directory.
    public lazy var isFolder: Bool = {
        resolvedURL.isFolder
    }()

    /// True if this directory has no contents. (Check ``isFolder`` first.)
    public var isEmptyFolder: Bool {
        (try? Self.fileManager.contentsOfDirectory(
            at: resolvedURL,
            includingPropertiesForKeys: nil,
            options: .skipsSubdirectoryDescendants
        ).isEmpty) ?? true
    }

    /// True if this is the workspace's root folder.
    public var isRoot: Bool { parent == nil }

    /// True if the file exists on disk.
    public var doesExist: Bool { Self.fileManager.fileExists(atPath: self.url.path) }

    /// The file's UTType.
    public var contentType: UTType? { url.contentType }

    public init(
        id: String,
        url: URL,
        changeType: GitStatus? = nil,
        staged: Bool? = false
    ) {
        self.id = id
        self.url = url
        self.gitStatus = changeType
        self.staged = staged
    }

    public convenience init(
        url: URL,
        changeType: GitStatus? = nil,
        staged: Bool? = false
    ) {
        self.init(id: url.relativePath, url: url, changeType: changeType, staged: staged)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, url, changeType, staged
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        url = try values.decode(URL.self, forKey: .url)
        gitStatus = try values.decode(GitStatus.self, forKey: .changeType)
        staged = try values.decode(Bool.self, forKey: .staged)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(gitStatus, forKey: .changeType)
        try container.encode(staged, forKey: .staged)
    }

    /// Returns the file name, optionally without its extension.
    public func fileName(typeHidden: Bool = false) -> String {
        typeHidden
            ? url.deletingPathExtension().lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
            : name
    }

    /// Parent directory for a file, or self for a folder.
    public var nearestFolder: URL {
        isFolder ? url : url.deletingLastPathComponent()
    }

    // MARK: Statics

    /// `FileManager.default` is documented thread-safe; the shared instance is only read from here.
    nonisolated(unsafe) public static let fileManager = FileManager.default

    // MARK: Comparable / Hashable

    public static func == (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.id == rhs.id
    }

    public static func < (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(id)
    }
}
