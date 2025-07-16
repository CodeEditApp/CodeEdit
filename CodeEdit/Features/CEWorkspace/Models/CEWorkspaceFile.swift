//
//  FileItem.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Combine

/// An object containing all necessary information and actions for a specific file in the workspace
///
/// The ``CEWorkspaceFile`` represents every type of file that can exist on the file system. Directories, files,
/// symlinks, etc. This class does not assume anything about what it is representing, but it can be interrogated to find
/// out what it represents. All information about the file is derived from the `URL` passed to the initializer of the
/// object.
///
/// This object works to provide a consistent API for any component that needs to work with files, and is as small as
/// possible.
///
/// These objects should be fetched from the ``CEWorkspaceFileManager`` whenever possible. Objects fetched from there
/// will be connected in CodeEdit's file tree, and structural properties like ``CEWorkspaceFile/parent`` will exist.
/// They can, however, be created standalone when necessary. Creating a standalone ``CEWorkspaceFile`` is useful if
/// loading all intermediate subdirectories (from the nearest cached parent to the file) has not been done yet and doing
/// so would be unnecessary.
///
/// An example of this is in the ``OpenQuicklyView``. This view finds a file URL via a search bar, and needs to display
/// a quick preview of the file. There's a good chance the file is deep in some subdirectory of the workspace, so
/// fetching it from the ``CEWorkspaceFileManager`` may require loading and caching multiple directories. Instead, it
/// just makes a disconnected object and uses it for the preview. Then, when opening the file in the workspace it
/// forces the file to be loaded and cached.
final class CEWorkspaceFile: Codable, Comparable, Hashable, Identifiable, EditorTabRepresentable {

    /// The id of the ``CEWorkspaceFile``.
    var id: String

    /// Returns the file name (e.g.: `Package.swift`)
    var name: String { url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Returns the extension of the file or an empty string if no extension is present.
    var type: FileIcon.FileType {
        let filename = url.fileName

        /// First, check if there is a valid file extension.
        if let type = FileIcon.FileType(rawValue: filename) {
            return type
        } else {
            /// If  there's not, verifies every extension for a valid type.
            let extensions = filename.dropFirst().components(separatedBy: ".").reversed()

            return extensions
                .compactMap { FileIcon.FileType(rawValue: $0) }
                .first
            /// Returns .txt for invalid type.
            ?? .txt
        }
    }

    /// Returns the URL of the ``CEWorkspaceFile``
    let url: URL

    /// Returns the resolved symlink url of this object.
    lazy var resolvedURL: URL = {
        url.isSymbolicLink ? url.resolvingSymlinksInPath() : url
    }()

    /// Return the icon of the file as `Image`
    var icon: Image {
        if let customImage = NSImage.symbol(named: systemImage) {
            return Image(nsImage: customImage)
        } else {
            return Image(systemName: systemImage)
        }
    }

    /// Return the icon of the file as `NSImage`
    var nsIcon: NSImage {
        if let customImage = NSImage.symbol(named: systemImage) {
            return customImage
        } else {
            return NSImage(systemSymbolName: systemImage, accessibilityDescription: systemImage)
                ?? NSImage(systemSymbolName: "doc", accessibilityDescription: "doc")!
        }
    }

    /// Returns a parent ``CEWorkspaceFile``.
    ///
    /// If the item already is the top-level ``CEWorkspaceFile`` this returns `nil`.
    weak var parent: CEWorkspaceFile?

    private let fileDocumentSubject = PassthroughSubject<CodeFileDocument?, Never>()

    weak var fileDocument: CodeFileDocument? {
        didSet {
            fileDocumentSubject.send(fileDocument)
        }
    }

    /// Publisher for fileDocument property
    var fileDocumentPublisher: AnyPublisher<CodeFileDocument?, Never> {
        fileDocumentSubject.eraseToAnyPublisher()
    }

    var fileIdentifier = UUID().uuidString

    /// Returns the Git status of a file as ``GitStatus``
    var gitStatus: GitStatus?

    /// Returns a boolean that is true if the file is staged for commit
    var staged: Bool?

    /// Returns the `id` in ``EditorTabID`` enum form
    var tabID: EditorTabID { .codeEditor(id) }

    /// Returns a boolean that is true if the resource represented by this object is a directory.
    lazy var isFolder: Bool = {
        resolvedURL.isFolder
    }()

    /// Returns a boolean that is true if the contents of the directory at this path are
    ///
    /// Does not indicate if this is a folder, see ``isFolder`` to first check if this object is also a directory.
    var isEmptyFolder: Bool {
        (try? CEWorkspaceFile.fileManager.contentsOfDirectory(
            at: resolvedURL,
            includingPropertiesForKeys: nil,
            options: .skipsSubdirectoryDescendants
        ).isEmpty) ?? true
    }

    /// Returns a boolean that is true if the file item is the root folder of the workspace.
    var isRoot: Bool { parent == nil }

    /// Returns a boolean that is true if the file item actually exists in the file system
    var doesExist: Bool { CEWorkspaceFile.fileManager.fileExists(atPath: self.url.path) }

    /// Returns a string describing a SFSymbol for the current ``CEWorkspaceFile``
    ///
    /// Use it like this
    /// ```swift
    /// Image(systemName: item.systemImage)
    /// ```
    var systemImage: String {
        if isFolder {
            // item is a folder
            return folderIcon()
        } else {
            // item is a file
            return FileIcon.fileIcon(fileType: type)
        }
    }

    /// Return the file's UTType
    var contentType: UTType? {
        url.contentType
    }

    /// Returns a `Color` for a specific `fileType`
    ///
    /// If not specified otherwise this will return `Color.accentColor`
    var iconColor: Color {
        FileIcon.iconColor(fileType: type)
    }

    init(
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

    convenience init(
        url: URL,
        changeType: GitStatus? = nil,
        staged: Bool? = false
    ) {
        self.init(
            id: url.relativePath,
            url: url,
            changeType: changeType,
            staged: staged
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case changeType
        case staged
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        url = try values.decode(URL.self, forKey: .url)
        gitStatus = try values.decode(GitStatus.self, forKey: .changeType)
        staged = try values.decode(Bool.self, forKey: .staged)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(gitStatus, forKey: .changeType)
        try container.encode(staged, forKey: .staged)
    }

    /// Returns a string describing a SFSymbol for folders
    ///
    /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
    /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
    /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
    private func folderIcon() -> String {
        if self.parent == nil {
            return "folder.fill.badge.gearshape"
        }
        if self.name == ".codeedit" {
            return "folder.fill.badge.gearshape"
        }
        return isEmptyFolder ? "folder" : "folder.fill"
    }

    /// Returns the file name with optional extension (e.g.: `Package.swift`)
    func fileName(typeHidden: Bool = false) -> String {
        typeHidden ? url.deletingPathExtension()
            .lastPathComponent
            .trimmingCharacters(in: .whitespacesAndNewlines) : name
    }

    /// Generates a string based on user's file name preferences.
    /// - Returns: A `String` suitable for display.
    func labelFileName() -> String {
        let prefs = Settings.shared.preferences.general
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return self.fileName(typeHidden: true)
        case .showAll:
            return self.fileName(typeHidden: false)
        case .showOnly:
            return self.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(self.type.rawValue))
        case .hideOnly:
            return self.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(self.type.rawValue))
        }
    }

    func validateFileName(for newName: String) -> Bool {
        // Name must be: new, nonempty, valid characters, and not exist in the filesystem.
        guard newName != labelFileName() &&
                !newName.isEmpty &&
                newName.isValidFilename &&
                !FileManager.default.fileExists(
                    atPath: self.url.deletingLastPathComponent().appending(path: newName).path
                ) else {
            return false
        }

        return true
    }

    /// Loads the ``fileDocument`` property with a new ``CodeFileDocument`` and registers it with the shared
    /// ``CodeEditDocumentController``.
    func loadCodeFile() throws {
        let codeFile = try CodeFileDocument(contentsOf: resolvedURL, ofType: contentType?.identifier ?? "")
        CodeEditDocumentController.shared.addDocument(codeFile)
        self.fileDocument = codeFile
    }

    // MARK: Statics
    /// The default `FileManager` instance
    static let fileManager = FileManager.default

    // MARK: Intents
    /// Allows the user to view the file or folder in the finder application
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Allows the user to launch the file or folder as it would be in finder
    func openWithExternalEditor() {
        NSWorkspace.shared.open(url)
    }

    /// Nearest folder refers to the parent directory if this is a non-folder item, or itself if the item is a folder.
    var nearestFolder: URL {
        (self.isFolder ?
                    self.url :
                    self.url.deletingLastPathComponent())
    }

    // MARK: Comparable

    static func == (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }

    // MARK: Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(id)
    }

}
