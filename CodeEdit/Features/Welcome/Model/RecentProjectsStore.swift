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
    private static let defaultsKey = "recentProjectPaths"
    static let didUpdateNotification = Notification.Name("RecentProjectsStore.didUpdate")

    static func recentProjectPaths() -> [String] {
        UserDefaults.standard.array(forKey: defaultsKey) as? [String] ?? []
    }

    static func recentProjectURLs() -> [URL] {
        recentProjectPaths().map { URL(filePath: $0) }
    }

    private static func setPaths(_ paths: [String]) {
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
        UserDefaults.standard.setValue(Array(paths.prefix(100)), forKey: defaultsKey)
        setDocumentControllerRecents()
        donateSearchableItems()
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    /// Notify the store that a url was opened.
    /// Moves the path to the front if it was in the list already, or prepends it.
    /// Saves the list to defaults when called.
    /// - Parameter url: The url that was opened. Any url is accepted. File, directory, https.
    static func documentOpened(at url: URL) {
        var paths = recentProjectURLs()
        if let containedIndex = paths.firstIndex(where: { $0.componentCompare(url) }) {
            paths.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
        } else {
            paths.insert(url, at: 0)
        }
        setPaths(paths.map { $0.path(percentEncoded: false) })
    }

    /// Remove all paths in the set.
    /// - Parameter paths: The paths to remove.
    /// - Returns: The remaining urls in the recent projects list.
    static func removeRecentProjects(_ paths: Set<URL>) -> [URL] {
        var recentProjectPaths = recentProjectURLs()
        recentProjectPaths.removeAll(where: { paths.contains($0) })
        setPaths(recentProjectPaths.map { $0.path(percentEncoded: false) })
        return recentProjectURLs()
    }

    static func clearList() {
        setPaths([])
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
