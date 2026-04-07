//
//  ThemeRepository.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 07.04.26.
//

import Foundation

/// Handles all file I/O operations for themes.
///
/// This separates disk operations from state management (ThemeModel),
/// making file operations independently testable and the data flow clearer.
struct ThemeRepository {
    let themesURL: URL
    let bundledThemesURL: URL?
    let fileManager: FileManager

    init(
        themesURL: URL,
        bundledThemesURL: URL?,
        fileManager: FileManager = .default
    ) {
        self.themesURL = themesURL
        self.bundledThemesURL = bundledThemesURL
        self.fileManager = fileManager
    }

    // MARK: - Loading

    /// Loads a single theme from a URL.
    func loadTheme(from url: URL) throws -> Theme {
        let json = try Data(contentsOf: url)
        return try JSONDecoder().decode(Theme.self, from: json)
    }

    /// Discovers and loads all themes from user and bundled directories.
    /// Applies overrides from settings and marks bundled themes.
    func loadAllThemes(
        overrides: [String: [String: [String: Theme.Attributes]]]
    ) throws -> [Theme] {
        ensureThemesDirectoryExists()

        let userURLs = themeFileURLs(in: themesURL)
        let bundledURLs = bundledThemesURL.map { themeFileURLs(in: $0) } ?? []
        let allURLs = userURLs + bundledURLs

        var themes: [Theme] = []
        for url in allURLs {
            guard var theme = try? loadTheme(from: url) else { continue }

            applyOverrides(to: &theme, overrides: overrides)
            theme.isBundled = bundledThemesURL.map { url.path.contains($0.path) } ?? false
            theme.fileURL = url
            themes.append(theme)
        }

        return themes
    }

    // MARK: - Saving

    /// Saves a theme to its file URL as pretty-printed JSON.
    func save(_ theme: Theme) throws {
        guard let fileURL = theme.fileURL else { return }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(theme)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: fileURL, options: .atomic)
    }

    // MARK: - Delete

    /// Removes a theme file from disk.
    func delete(_ theme: Theme) throws {
        guard let url = theme.fileURL else { return }
        try fileManager.removeItem(at: url)
    }

    // MARK: - Rename

    /// Moves a theme file to a new name, resolving conflicts.
    /// Returns the new file URL.
    func rename(_ theme: Theme, to newName: String, existingNames: [String]) throws -> URL {
        guard let oldURL = theme.fileURL else {
            throw NSError(
                domain: "ThemeRepository",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Theme file URL not found"]
            )
        }

        var finalName = newName
        var finalURL = themesURL.appending(path: finalName).appendingPathExtension("cetheme")
        var iterator = 1

        while existingNames.contains(where: { $0 == finalName && finalName != theme.displayName }) {
            finalName = "\(newName) \(iterator)"
            finalURL = themesURL.appending(path: finalName).appendingPathExtension("cetheme")
            iterator += 1
        }

        try fileManager.moveItem(at: oldURL, to: finalURL)
        return finalURL
    }

    // MARK: - Duplicate / Import

    /// Copies a theme file to the themes directory, resolving filename conflicts.
    /// Returns the destination URL and resolved filename.
    func duplicateFile(from sourceURL: URL) throws -> (url: URL, name: String) {
        var destinationURL = themesURL.appending(path: sourceURL.lastPathComponent)
        let fileExtension = destinationURL.pathExtension
        var fileName = destinationURL.deletingPathExtension().lastPathComponent
        var newFileName = fileName
        var iterator = 1

        let isBundled = bundledThemesURL.map { sourceURL.absoluteString.hasPrefix($0.absoluteString) } ?? false

        if isBundled {
            newFileName = "\(fileName) \(iterator)"
            destinationURL = themesURL
                .appending(path: newFileName)
                .appendingPathExtension(fileExtension)
        }

        while fileManager.fileExists(atPath: destinationURL.path) {
            fileName = destinationURL.deletingPathExtension().lastPathComponent
            if let range = fileName.range(of: " \\d+$", options: .regularExpression) {
                fileName = String(fileName[..<range.lowerBound])
            }
            newFileName = "\(fileName) \(iterator)"
            destinationURL = themesURL
                .appending(path: newFileName)
                .appendingPathExtension(fileExtension)
            iterator += 1
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return (destinationURL, newFileName)
    }

    // MARK: - Private Helpers

    private func ensureThemesDirectoryExists() {
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: themesURL.path, isDirectory: &isDir) {
            try? fileManager.createDirectory(at: themesURL, withIntermediateDirectories: true)
        }
    }

    private func themeFileURLs(in directory: URL) -> [URL] {
        let filenames = (try? fileManager.contentsOfDirectory(atPath: directory.path)) ?? []
        return filenames
            .filter { $0.hasSuffix(".cetheme") }
            .map { directory.appending(path: $0) }
    }

    private func applyOverrides(
        to theme: inout Theme,
        overrides: [String: [String: [String: Theme.Attributes]]]
    ) {
        guard let terminalColors = try? theme.terminal.allProperties() as? [String: Theme.Attributes],
              let editorColors = try? theme.editor.allProperties() as? [String: Theme.Attributes]
        else { return }

        if let terminalOverrides = overrides[theme.name]?["terminal"] {
            for key in terminalColors.keys {
                if let attributes = terminalOverrides[key] {
                    theme.terminal[key] = attributes
                }
            }
        }

        if let editorOverrides = overrides[theme.name]?["editor"] {
            for key in editorColors.keys {
                if let attributes = editorOverrides[key] {
                    theme.editor[key] = attributes
                }
            }
        }
    }
}
