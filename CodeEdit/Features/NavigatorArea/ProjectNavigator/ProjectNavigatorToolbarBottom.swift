//
//  ProjectNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by TAY KAI QUAN on 23/7/22.
//

import SwiftUI

struct ProjectNavigatorToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var editorManager: EditorManager

    @State var recentsFilter: Bool = false

    var body: some View {
        NavigatorFilterView(
            text: $workspace.navigatorFilter,
            hasValue: { !workspace.navigatorFilter.isEmpty || recentsFilter || workspace.sourceControlFilter },
            menu: { addNewFileButton },
            leadingAccessories: { leadingAccessories },
            trailingAccessories: { trailingAccessories }
        )
    }

    @ViewBuilder private var leadingAccessories: some View {
        FilterDropDownIconButton(menu: {
            ForEach([(true, "Folders on top"), (false, "Alphabetically")], id: \.0) { value, title in
                Toggle(title, isOn: Binding(get: {
                    workspace.sortFoldersOnTop == value
                }, set: { _ in
                    // Avoid calling the handleFilterChange method
                    if workspace.sortFoldersOnTop != value {
                        workspace.sortFoldersOnTop = value
                    }
                }))
            }
        }, isOn: !workspace.navigatorFilter.isEmpty)
        .padding(.leading, 4)
        .foregroundStyle(
            workspace.navigatorFilter.isEmpty
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
            Toggle(isOn: $workspace.sourceControlFilter) {
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
        if let selectedTab = editorManager.activeEditor.selectedTab {
            if selectedTab.file.isFolder {
                return selectedTab.file.url
            }

            // If the current active tab belongs to a file, pop the filename from
            // the path URL to retrieve the folder URL
            let activeTabFileURL = selectedTab.file.url

            if URLComponents(url: activeTabFileURL, resolvingAgainstBaseURL: false) != nil {
                var pathComponents = activeTabFileURL.pathComponents
                pathComponents.removeLast()

                let fileURL = NSURL.fileURL(withPathComponents: pathComponents)! as URL
                return fileURL
            }
        }

        return workspace.workspaceFileManager.unsafelyUnwrapped.folderUrl
    }

    @ViewBuilder private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
                do {
                    if let newFile = try workspace.workspaceFileManager?.addFile(
                        fileName: "untitled",
                        toFile: rootFile
                    ) {
                        workspace.listenerModel.highlightedFileItem = newFile
                        workspace.editorManager?.openTab(item: newFile)
                    }
                } catch {
                    let alert = NSAlert(error: error)
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                }
            }

            Button("Add Folder") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
                do {
                    if let newFolder = try workspace.workspaceFileManager?.addFolder(
                        folderName: "untitled",
                        toFile: rootFile
                    ) {
                        workspace.listenerModel.highlightedFileItem = newFolder
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
            workspace.navigatorFilter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
