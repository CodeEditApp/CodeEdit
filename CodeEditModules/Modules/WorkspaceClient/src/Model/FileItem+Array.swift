//
//  File.swift
//
//
//  Created by Lukas Pistrol on 17.03.22.
//

import Foundation

public extension Array where Element == WorkspaceClient.FileItem {
    func sortItems(foldersOnTop: Bool) -> Self {
        var alphabetically = sorted { $0.fileName < $1.fileName }

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
