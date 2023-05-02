//
//  CEWorkspaceFile+Recursion.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 30/04/2023.
//

import Foundation

extension CEWorkspaceFile {

    func childrenDescription(tabCount: Int) -> String {
        var myDetails = "\(String(repeating: "|  ", count: max(tabCount - 1, 0)))\(tabCount != 0 ? "╰--" : "")"
        myDetails += "\(url.path)"
        if !self.isFolder { // if im a file, just return the url
            return myDetails
        } else { // if im a folder, return the url and its children's details
            var childDetails = "\(myDetails)"
            for child in children ?? [] {
                childDetails += "\n\(child.childrenDescription(tabCount: tabCount + 1))"
            }
            return childDetails
        }
    }

    /// Flattens the children of ``self`` recursively with depth.
    /// - Parameters:
    ///   - depth: An int that indicates the how deep the tree files need to be flattened
    ///   - ignoringFolders: A boolean on whether to ignore files that are Folders
    /// - Returns: An array of flattened `CEWorkspaceFiles`
    func flattenedChildren(withDepth depth: Int, ignoringFolders: Bool) -> [CEWorkspaceFile] {
        guard depth > 0 else { return [] }
        guard self.isFolder else { return [self] }
        var childItems: [CEWorkspaceFile] = ignoringFolders ? [] : [self]
        children?.forEach { child in
            childItems.append(contentsOf: child.flattenedChildren(
                withDepth: depth - 1,
                ignoringFolders: ignoringFolders
            ))
        }
        return childItems
    }

    /// Returns a list of `CEWorkspaceFiles` that are sibilings of ``self``.
    /// The `height` parameter lets the function navigate up the folder hierarchy to
    /// select a starting point from which it should start flettening the items.
    /// - Parameters:
    ///   - height: `Int` that tells where to start in the hierarchy
    ///   - ignoringFolders: Wether the sibling folders should be flattened
    /// - Returns: A list of `FileSystemItems`
    func flattenedSiblings(withHeight height: Int, ignoringFolders: Bool) -> [CEWorkspaceFile] {
        let topMostParent = self.getParent(withHeight: height)
        return topMostParent.flattenedChildren(withDepth: height, ignoringFolders: ignoringFolders)
    }

    /// Recursive function that returns the number of children
    /// that contain the `searchString` in their path or their subitems' paths.
    /// Returns `0` if the item is not a folder.
    /// - Parameters:
    ///   - searchString: The string
    ///   - ignoredStrings: The prefixes to ignore if they prefix file names
    /// - Returns: The number of children that match the conditiions
    func appearanceWithinChildrenOf(searchString: String, ignoredStrings: [String] = [".", "~"]) -> Int {
        var count = 0
        guard self.isFolder else { return 0 }
        for child in self.children ?? [] {
            var isIgnored: Bool = false
            for ignoredString in ignoredStrings where child.name.hasPrefix(ignoredString) {
                isIgnored = true // can use regex later
            }

            if isIgnored {
                continue
            }

            guard !searchString.isEmpty else { count += 1; continue }
            if child.isFolder {
                count += child.appearanceWithinChildrenOf(searchString: searchString) > 0 ? 1 : 0
            } else {
                count += child.name.lowercased().contains(searchString.lowercased()) ? 1 : 0
            }
        }
        return count
    }

    /// Function that returns an array of the children
    /// that contain the `searchString` in their path or their subitems' paths.
    /// Similar to `appearanceWithinChildrenOf(searchString: String)`
    /// Returns `[]` if the item is not a folder.
    /// - Parameter searchString: The string
    /// - Parameter ignoredStrings: The prefixes to ignore if they prefix file names
    /// - Returns: The children that match the conditiions
    func childrenSatisfying(searchString: String, ignoredStrings: [String] = [".", "~"]) -> [CEWorkspaceFile] {
        var satisfyingChildren: [CEWorkspaceFile] = []
        guard self.isFolder else { return [] }
        for child in self.children ?? [] {
            var isIgnored: Bool = false
            for ignoredString in ignoredStrings where child.name.hasPrefix(ignoredString) {
                isIgnored = true // can use regex later
            }

            if isIgnored {
                continue
            }

            guard !searchString.isEmpty else { satisfyingChildren.append(child); continue }
            if child.isFolder {
                if child.appearanceWithinChildrenOf(searchString: searchString) > 0 {
                    satisfyingChildren.append(child)
                }
            } else {
                if child.name.lowercased().contains(searchString.lowercased()) {
                    satisfyingChildren.append(child)
                }
            }
        }
        return satisfyingChildren
    }

    /// Using the current instance of `FileSystemItem` it will walk back up the Workspace file hiarchy
    /// the amount of times specified with the `withHeight` parameter.
    /// - Parameter height: The amount of times you want to up a folder.
    /// - Returns: The found `FileSystemItem` object, This should always be a folder.
    private func getParent(withHeight height: Int) -> CEWorkspaceFile {
        var topmostParent = self
        for _ in 0..<height {
            guard let parent = topmostParent.parent else { break }
            topmostParent = parent
        }

        return topmostParent
    }

}
