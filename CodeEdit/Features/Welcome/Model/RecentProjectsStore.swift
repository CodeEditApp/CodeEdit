//
//  RecentProjectsUtil.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import AppKit
import CoreSpotlight

/// Helper methods for managing the recent projects list and donating list items to CoreSpotlight.
///
/// Limits the number of remembered projects to 100 items.
///
/// If a UI element needs to listen to changes in this list, listen for the
/// ``RecentProjectsStore/didUpdateNotification`` notification.
enum RecentProjectsStore {
    private static let projectsdDefaultsKey = "recentProjectPaths"
    private static let fileDefaultsKey = "recentFilePaths"
    static let didUpdateNotification = Notification.Name("RecentProjectsStore.didUpdate")

    static func recentProjectPaths() -> [String] {
        UserDefaults.standard.array(forKey: projectsdDefaultsKey) as? [String] ?? []
    }

    static func recentProjectURLs() -> [URL] {
        return recentProjectPaths().map { URL(filePath: $0) }
    }

    static func recentFilePaths() -> [String] {
        UserDefaults.standard.array(forKey: fileDefaultsKey) as? [String] ?? []
    }

    static func recentFileURLs() -> [URL] {
        return recentFilePaths().map { URL(filePath: $0) }
    }

    private static func setProjectPaths(_ paths: [String]) {
        var paths = paths
        // Remove duplicates
        var foundPaths = Set<String>()
        for (idx, path) in paths.enumerated().reversed() {
            if foundPaths.contains(path) {
                paths.remove(at: idx)
            } else {
                foundPaths.insert(path)
            }
        }

        // Limit list to to 100 items after de-duplication
        UserDefaults.standard.setValue(Array(paths.prefix(100)), forKey: projectsdDefaultsKey)
        setDocumentControllerRecents()
        donateSearchableItems()
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }
    private static func setFilePaths(_ paths: [String]) {
        var paths = paths
        // Remove duplicates
        var foundPaths = Set<String>()
        for (idx, path) in paths.enumerated().reversed() {
            if foundPaths.contains(path) {
                paths.remove(at: idx)
            } else {
                foundPaths.insert(path)
            }
        }

        // Limit list to to 100 items after de-duplication
        UserDefaults.standard.setValue(Array(paths.prefix(100)), forKey: fileDefaultsKey )
        setDocumentControllerRecents()
        donateSearchableItems()
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    /// Notify the store that a url was opened.
    /// Moves the path to the front if it was in the list already, or prepends it.
    /// Saves the list to defaults when called.
    /// - Parameter url: The url that was opened. Any url is accepted. File, directory, https.
    static func documentOpened(at url: URL) {
        var projPaths = recentProjectURLs()
        var filePaths = recentFileURLs()

        let urlToString = url.absoluteString

        // if file portion of local URL has "/" at the end then it is a folder , files and folders go in two separate lists

        if  urlToString.hasSuffix("/") {
            if let containedIndex = projPaths.firstIndex(where: { $0.componentCompare(url) }) {
                projPaths.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
            } else {
                projPaths.insert(url, at: 0)
            }
            setProjectPaths(projPaths.map { $0.path(percentEncoded: false) })
        } else {
            if let containedIndex = filePaths.firstIndex(where: { $0.componentCompare(url) }) {
                filePaths.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
            } else {
                filePaths.insert(url, at: 0)
            }
            setFilePaths(filePaths.map { $0.path(percentEncoded: false) })
        }
    }

    /// Remove all project paths in the set.
    /// - Parameter paths: The paths to remove.
    /// - Returns: The remaining urls in the recent projects list.
    static func removeRecentProjects(_ paths: Set<URL>) -> [URL] {
        var recentProjectPaths = recentProjectURLs()
        recentProjectPaths.removeAll(where: { paths.contains($0) })
        setProjectPaths(recentProjectPaths.map { $0.path(percentEncoded: false) })
        return recentProjectURLs()
    }
    /// Remove all folder paths in the set.
    /// - Parameter paths: The paths to remove.
    /// - Returns: The remaining urls in the recent projects list.
    static func removeRecentFiles(_ paths: Set<URL>) -> [URL] {
        var recentFilePaths = recentFileURLs()
        recentFilePaths.removeAll(where: { paths.contains($0) })
        setFilePaths(recentFilePaths.map { $0.path(percentEncoded: false) })
        return recentFileURLs()
    }

    static func clearList() {
        setProjectPaths([])
        setFilePaths([])
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    /// Syncs AppKit's recent documents list with ours, keeping the dock menu and other lists up-to-date.
    private static func setDocumentControllerRecents() {
        CodeEditDocumentController.shared.clearRecentDocuments(nil)
        for path in recentProjectURLs().prefix(10) {
            CodeEditDocumentController.shared.noteNewRecentDocumentURL(path)
        }
    }

    /// Donates all recent URLs to Core Search, making them searchable in Spotlight
    private static func donateSearchableItems() {
        let searchableItems = recentProjectURLs().map { entity in
            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.title = entity.lastPathComponent
            attributeSet.relatedUniqueIdentifier = entity.path()
            return CSSearchableItem(
                uniqueIdentifier: entity.path(),
                domainIdentifier: "app.codeedit.CodeEdit.ProjectItem",
                attributeSet: attributeSet
            )
        }
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print(error)
            }
        }
    }
}
