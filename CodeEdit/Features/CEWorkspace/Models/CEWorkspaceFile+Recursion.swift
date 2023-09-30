//
//  CEWorkspaceFile+Recursion.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 30/04/2023.
//

import Foundation

extension CEWorkspaceFile {

    #if DEBUG
    func childrenDescription(tabCount: Int) -> String {
        var myDetails = "\(String(repeating: "|  ", count: max(tabCount - 1, 0)))\(tabCount != 0 ? "╰--" : "")"
        myDetails += "\(url.path)"
        if !self.isFolder { // if im a file, just return the url
            return myDetails
        } else { // if im a folder, return the url and its children's details
            var childDetails = "\(myDetails)"
//            for child in children ?? [] {
//                childDetails += "\n\(child.childrenDescription(tabCount: tabCount + 1))"
//            }
            return childDetails
        }
    }
    #endif

    /// Flattens the children of ``self`` recursively with depth.
    /// - Parameters:
    ///   - depth: An int that indicates the how deep the tree files need to be flattened
    ///   - ignoringFolders: A boolean on whether to ignore files that are Folders
    /// - Returns: An array of flattened `CEWorkspaceFiles`
    func flattenedChildren(withDepth depth: Int, ignoringFolders: Bool) -> [CEWorkspaceFile] {
        guard depth > 0 else { return [] }
        guard self.isFolder else { return [self] }
        var childItems: [CEWorkspaceFile] = ignoringFolders ? [] : [self]
//        children?.forEach { child in
//            childItems.append(contentsOf: child.flattenedChildren(
//                withDepth: depth - 1,
//                ignoringFolders: ignoringFolders
//            ))
//        }
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
