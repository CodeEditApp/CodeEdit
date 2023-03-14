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
