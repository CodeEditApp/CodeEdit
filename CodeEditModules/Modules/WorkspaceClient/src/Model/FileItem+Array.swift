//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 17.03.22.
//

import Foundation

extension Array where Element == WorkspaceClient.FileItem {
	public func sortItems(foldersOnTop: Bool) -> Self {
		var alphabetically = self.sorted { $0.fileName < $1.fileName }

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
