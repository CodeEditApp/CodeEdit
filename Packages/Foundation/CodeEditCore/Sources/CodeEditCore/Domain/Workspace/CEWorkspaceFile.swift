//
//  CEWorkspaceFile.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation
import UniformTypeIdentifiers
import Combine

/// A file, folder, or symlink in the workspace. This is the UI-free model; presentation,
/// AppKit intents, name-labeling, and editor-document coupling live in app-side extensions.
public final class CEWorkspaceFile: Codable, Comparable, Hashable, Identifiable {

    /// The id of the ``CEWorkspaceFile``.
    public var id: String

    /// Returns the file name (e.g.: `Package.swift`)
    public var name: String { url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// The file's ``FileType`` derived from its extension (defaults to `.txt`).
    public var type: FileType {
        let filename = url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
        if let type = FileType(rawValue: filename) {
            return type
        } else {
            let extensions = filename.dropFirst().components(separatedBy: ".").reversed()
            return extensions.compactMap { FileType(rawValue: $0) }.first ?? .txt
        }
    }

    /// Returns the URL of the ``CEWorkspaceFile``
    public let url: URL

    /// Returns the resolved symlink url of this object.
    public lazy var resolvedURL: URL = {
        Self.isSymbolicLink(url) ? url.resolvingSymlinksInPath() : url
    }()

    /// Returns a parent ``CEWorkspaceFile``. `nil` for the top-level item.
    public weak var parent: CEWorkspaceFile?

    private let fileDocumentSubject = PassthroughSubject<AnyObject?, Never>()

    /// Type-erased weak reference to the file's open document (a `CodeFileDocument` in the app).
    /// The app's `CEWorkspaceFile+Editor` extension provides a typed `fileDocument` accessor.
    public weak var fileDocumentObject: AnyObject? {
        didSet { fileDocumentSubject.send(fileDocumentObject) }
    }

    /// Publisher for ``fileDocumentObject``.
    public var fileDocumentObjectPublisher: AnyPublisher<AnyObject?, Never> {
        fileDocumentSubject.eraseToAnyPublisher()
    }

    public var fileIdentifier = UUID().uuidString

    /// The Git status of the file.
    public var gitStatus: GitStatus?

    /// Whether the file is staged for commit.
    public var staged: Bool?

    /// True if the resource is a directory.
    public lazy var isFolder: Bool = {
        Self.isDirectory(resolvedURL)
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
    public var contentType: UTType? { Self.contentType(url) }

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

    private static func resourceValues(_ url: URL) -> URLResourceValues? {
        try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentTypeKey])
    }

    private static func isDirectory(_ url: URL) -> Bool {
        resourceValues(url)?.isDirectory ?? false
    }

    private static func isSymbolicLink(_ url: URL) -> Bool {
        let values = resourceValues(url)
        return (values?.isSymbolicLink ?? false) || (values?.contentType ?? .item) == .aliasFile
    }

    private static func contentType(_ url: URL) -> UTType? {
        resourceValues(url)?.contentType
    }

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
