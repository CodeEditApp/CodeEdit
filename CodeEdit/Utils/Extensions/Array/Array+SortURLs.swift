//
//  Array+FileSystem.FileItem.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation

extension Array where Element == URL {

    /// Sorts the elements in alphabetical order.
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    /// - Returns: A sorted array of `URL`
    func sortItems(foldersOnTop: Bool) -> [URL] {
        return self.sorted { lhs, rhs in
            let lhsIsDir = (try? lhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let rhsIsDir = (try? rhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false

            if foldersOnTop {
                if lhsIsDir != rhsIsDir {
                    return lhsIsDir
                }
            }

            return compareNaturally(lhs.lastPathComponent, rhs.lastPathComponent)
        }
    }

    /// Compare two strings using natural sorting.
    /// - Parameters:
    ///   - lhs: The left-hand string.
    ///   - rhs: The right-hand string.
    /// - Returns: `true` if `lhs` should be ordered before `rhs`.
    private func compareNaturally(_ lhs: String, _ rhs: String) -> Bool {
        let lhsComponents = lhs.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let rhsComponents = rhs.components(separatedBy: CharacterSet.decimalDigits.inverted)

        for (lhsPart, rhsPart) in zip(lhsComponents, rhsComponents) where lhsPart != rhsPart {
            if let lhsNum = Int(lhsPart), let rhsNum = Int(rhsPart) {
                return lhsNum < rhsNum
            } else {
                return lhsPart < rhsPart
            }
        }

        return lhs < rhs
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
