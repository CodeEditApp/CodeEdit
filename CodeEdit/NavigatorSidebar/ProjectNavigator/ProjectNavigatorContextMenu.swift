//
//  ProjectNavigatorContextMenu.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 26.03.22.
//

import SwiftUI
import WorkspaceClient

// TODO: Some implementations still need to be done
/// # Project Navigator Context Menu
///
/// A context menu which shows when right clicking on a folder or file
/// in the ``ProjectNavigator``.
///
struct ProjectNavigatorContextMenu: View {

	private var item: WorkspaceClient.FileItem
	private var isFolder: Bool

	init(_ item: WorkspaceClient.FileItem, isFolder: Bool) {
		self.item = item
		self.isFolder = isFolder
	}

	@ViewBuilder
    var body: some View {
		showInFinder
		openSection
		showFileInspector
		addSection
		delete
		newFolderSection
		sortSection
		findInSelectedGroups
		sourceControl
    }

	private var showInFinder: some View {
		Group {
			Button("Show in Finder") {
				item.showInFinder()
			}
			Divider()
		}
	}

	private var openSection: some View {
		Group {
			Button("Open in Tab") {
				// Open a new tab
			}
			Button("Open in New Window") {
				// Open a new window
			}
			Divider()
		}
	}

	private var showFileInspector: some View {
		Group {
			Button("Show File Inspector") {
				// Show File Inspector
			}
			Divider()
		}
	}

	private var addSection: some View {
		Group {
			Button("New File") {
				item.addFile(fileName: "randomFile.txt")
			}
			Button("Add files to folder") {
				// Add Files to Folder
			}
			Divider()
		}
	}

	private var delete: some View {
		Group {
			Button("Delete") {
				item.delete()
			}
			Divider()
		}
	}

	private var newFolderSection: some View {
		Group {
			Button("New Folder") {
				item.addFolder(folderName: "Test Folder")
			}
			Button("New Folder from Selection") {
				// New Group from Selection
			}
			Divider()
		}
	}

	private var sortSection: some View {
		Group {
			Button("Sort by Name") {
				// Sort folder items by name
			}
			.disabled(!isFolder)
			Button("Sort by Type") {
				// Sort folder items by file type
			}
			.disabled(!isFolder)
			Divider()
		}
	}

	private var findInSelectedGroups: some View {
		Group {
			Button("Find in Selected Groups...") {
				// Find in selected groups...
			}
			.disabled(!isFolder)
			Divider()
		}
	}

	private var sourceControl: some View {
		Menu("Source Control") {
			Button("Commit Selected File") {
				// Commit selected file
			}
			Divider()
			Button("Discard Changes in Selected File") {
				// Discard changes made to the selected file
			}
			Divider()
			Button("Add") {
				// Add file to git
			}
			Button("Mark as Resolved") {
				// Mark file as resolved
			}
		}
	}
}
