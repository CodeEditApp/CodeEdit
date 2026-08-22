//
//  ProjectNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by TAY KAI QUAN on 23/7/22.
//

import SwiftUI
import CEWorkspaceFileManager
import CodeEditUI
import CodeEditCore

struct ProjectNavigatorToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.activeEditorState)
    private var activeEditorState
    @Environment(\.workspaceNavigator)
    private var workspaceNavigator
    @EnvironmentObject var projectNavigatorViewModel: ProjectNavigatorViewModel

    @Environment(\.workspaceFileManager)
    private var workspaceFileManager

    @State var recentsFilter: Bool = false

    var body: some View {
        NavigatorFilterView(
            text: $projectNavigatorViewModel.navigatorFilter,
            hasValue: {
                !projectNavigatorViewModel.navigatorFilter.isEmpty
                    || recentsFilter
                    || projectNavigatorViewModel.sourceControlFilter
            },
            menu: { addNewFileButton },
            leadingAccessories: { leadingAccessories },
            trailingAccessories: { trailingAccessories }
        )
    }

    @ViewBuilder private var leadingAccessories: some View {
        FilterDropDownIconButton(menu: {
            ForEach([(true, "Folders on top"), (false, "Alphabetically")], id: \.0) { value, title in
                Toggle(title, isOn: Binding(get: {
                    projectNavigatorViewModel.sortFoldersOnTop == value
                }, set: { _ in
                    // Avoid calling the handleFilterChange method
                    if projectNavigatorViewModel.sortFoldersOnTop != value {
                        projectNavigatorViewModel.sortFoldersOnTop = value
                    }
                }))
            }
        }, isOn: !projectNavigatorViewModel.navigatorFilter.isEmpty)
        .padding(.leading, 4)
        .foregroundStyle(
            projectNavigatorViewModel.navigatorFilter.isEmpty
            ? Color(nsColor: .secondaryLabelColor)
            : Color(nsColor: .controlAccentColor)
        )
        .help("Show files with matching name")
    }

    @ViewBuilder private var trailingAccessories: some View {
        HStack(spacing: 0) {
            Toggle(isOn: $recentsFilter) {
                Image(systemName: "clock")
            }
            .help("Show only recent files")
            Toggle(isOn: $projectNavigatorViewModel.sourceControlFilter) {
                Image(systemName: "plusminus.circle")
            }
            .help("Show only files with source-control status")
        }
        .toggleStyle(.icon(font: .system(size: 14), size: CGSize(width: 18, height: 20)))
        .padding(.trailing, 2.5)
    }

    /// Retrieves the active tab URL from the underlying editor instance, if theres no
    /// active tab, fallbacks to the workspace's root directory
    private func activeTabURL() -> URL {
        if let file = activeEditorState.selectedFile {
            if file.isFolder {
                return file.url
            }

            // If the current active tab belongs to a file, pop the filename from
            // the path URL to retrieve the folder URL
            let activeTabFileURL = file.url

            if URLComponents(url: activeTabFileURL, resolvingAgainstBaseURL: false) != nil {
                var pathComponents = activeTabFileURL.pathComponents
                pathComponents.removeLast()

                let fileURL = NSURL.fileURL(withPathComponents: pathComponents)! as URL
                return fileURL
            }
        }

        return workspaceFileManager.unsafelyUnwrapped.folderUrl
    }

    @ViewBuilder private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspaceFileManager?.getFile(filePathURL.path) else { return }
                do {
                    if let newFile = try workspaceFileManager?.addFile(
                        fileName: "untitled",
                        toFile: rootFile
                    ) {
                        workspaceNavigator.reveal(file: newFile)
                        workspaceNavigator.open(file: newFile, asTemporary: false)
                    }
                } catch {
                    let alert = NSAlert(error: error)
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                }
            }

            Button("Add Folder") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspaceFileManager?.getFile(filePathURL.path) else { return }
                do {
                    if let newFolder = try workspaceFileManager?.addFolder(
                        folderName: "untitled",
                        toFile: rootFile
                    ) {
                        workspaceNavigator.reveal(file: newFolder)
                    }
                } catch {
                    let alert = NSAlert(error: error)
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                }
            }
        } label: {}
        .background {
            Image(systemName: "plus")
                .accessibilityHidden(true)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
        .opacity(activeState == .inactive ? 0.45 : 1)
        .accessibilityLabel("Add Folder or File")
        .accessibilityIdentifier("addButton")
    }

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearFilterButton: some View {
        Button {
            projectNavigatorViewModel.navigatorFilter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
