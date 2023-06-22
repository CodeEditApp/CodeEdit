//
//  Array+FileSystem.FileItem.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation

extension Array where Element == CEWorkspaceFile {
    /// Sorts the elements in alphabetical order.
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    /// - Returns: A sorted array of ``FileSystemClient/FileSystemClient/FileItem``
    func sortItems(foldersOnTop: Bool) -> Self {
        var alphabetically = sorted { $0.name < $1.name }

        if foldersOnTop {
            var foldersOnTop = alphabetically.filter { $0.children != nil }
            alphabetically.removeAll { $0.children != nil }

            foldersOnTop.append(contentsOf: alphabetically)

            return foldersOnTop
        } else {
            return alphabetically
        }
    }

    /// Appends file to collection in a sorted way
    /// - Parameter newFile: The new file to be added
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    mutating func appendSorted(_ newFile: CEWorkspaceFile, foldersOnTop: Bool) {
        if newFile.isFolder {
            var insertionIndex = 0

            if let firstIndex = self.firstIndex(where: { $0.isFolder && $0.name > newFile.name }) {
                insertionIndex = firstIndex
            } else if let lastIndex = self.lastIndex(where: { $0.isFolder }) {
                insertionIndex = lastIndex
            }

            self.insert(newFile, at: insertionIndex)
        } else if let firstIndex = self.firstIndex(where: { !$0.isFolder && $0.name > newFile.name }) {
            self.insert(newFile, at: firstIndex)
        } else {
            self.append(newFile)
        }
    }

    /// Removes file from collection
    /// - Parameter file: The new file to be removed
    mutating func remove(_ file: CEWorkspaceFile) {
        if let index = self.firstIndex(of: file) {
            self.remove(at: index)
        }
    }

    /// Search for the `CEWorkspaceFile` element that matches the specified `tabID`.
    /// - Parameter tabID: A `tabID` to search for.
    /// - Returns: The `CEWorkspaceFile` element with a matching `tabID` if available.
    func find(by tabID: TabBarItemID) -> CEWorkspaceFile? {
        guard let item = first(where: { $0.tabID == tabID }) else {
            for element in self {
                if let item = element.children?.find(by: tabID) {
                    return item
                }
            }
            return nil
        }
        return item
    }
}

extension Array where Element: Hashable {

    /// Checks the difference between two given items.
    /// - Parameter other: Other element
    /// - Returns: symmetricDifference
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
