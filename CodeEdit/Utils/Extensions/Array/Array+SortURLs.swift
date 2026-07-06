//
//  Array+FileSystem.FileItem.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation

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
