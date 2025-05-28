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
class RecentProjectsStore {
    /// The default projects store, uses the `UserDefaults.standard` storage location.
    static let shared = RecentProjectsStore()

    private static let projectsdDefaultsKey = "recentProjectPaths"
    static let didUpdateNotification = Notification.Name("RecentProjectsStore.didUpdate")

    /// The storage location for recent projects
    let defaults: UserDefaults

    /// Create a new store with a `UserDefaults` storage location.
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }

    /// Gets the recent paths array from `UserDefaults`.
    private func recentPaths() -> [String] {
        defaults.array(forKey: Self.projectsdDefaultsKey) as? [String] ?? []
    }

    /// Gets all recent paths from `UserDefaults` as an array of `URL`s. Includes both **projects** and
    /// **single files**.
    /// To filter for either projects or single files, use ``recentProjectURLs()`` or ``recentFileURLs``, respectively.
    func recentURLs() -> [URL] {
        recentPaths().map { URL(filePath: $0) }
    }

    /// Gets the recent **Project** `URL`s from `UserDefaults`.
    /// To get both single files and projects, use ``recentURLs()``.
    func recentProjectURLs() -> [URL] {
        recentURLs().filter { $0.isFolder }
    }

    /// Gets the recent **Single File** `URL`s from `UserDefaults`.
    /// To get both single files and projects, use ``recentURLs()``.
    func recentFileURLs() -> [URL] {
        recentURLs().filter { !$0.isFolder }
    }

    /// Save a new paths array to defaults. Automatically limits the list to the most recent `100` items, donates
    /// search items to Spotlight, and notifies observers.
    private func setPaths(_ paths: [String]) {
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
        defaults.setValue(Array(paths.prefix(100)), forKey: Self.projectsdDefaultsKey)
        setDocumentControllerRecents()
        donateSearchableItems()
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    /// Notify the store that a url was opened.
    /// Moves the path to the front if it was in the list already, or prepends it.
    /// Saves the list to defaults when called.
    /// - Parameter url: The url that was opened. Any url is accepted. File, directory, https.
    func documentOpened(at url: URL) {
        var projectURLs = recentURLs()

        if let containedIndex = projectURLs.firstIndex(where: { $0.componentCompare(url) }) {
            projectURLs.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
        } else {
            projectURLs.insert(url, at: 0)
        }

        setPaths(projectURLs.map { $0.path(percentEncoded: false) })
    }

    /// Remove all project paths in the set.
    /// - Parameter paths: The paths to remove.
    /// - Returns: The remaining urls in the recent projects list.
    func removeRecentProjects(_ paths: Set<URL>) -> [URL] {
        var recentProjectPaths = recentProjectURLs()
        recentProjectPaths.removeAll(where: { paths.contains($0) })
        setPaths(recentProjectPaths.map { $0.path(percentEncoded: false) })
        return recentProjectURLs()
    }

    func clearList() {
        setPaths([])
        NotificationCenter.default.post(name: Self.didUpdateNotification, object: nil)
    }

    /// Syncs AppKit's recent documents list with ours, keeping the dock menu and other lists up-to-date.
    private func setDocumentControllerRecents() {
        CodeEditDocumentController.shared.clearRecentDocuments(nil)
        for path in recentProjectURLs().prefix(10) {
            CodeEditDocumentController.shared.noteNewRecentDocumentURL(path)
        }
    }

    /// Donates all recent URLs to Core Search, making them searchable in Spotlight
    private func donateSearchableItems() {
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
