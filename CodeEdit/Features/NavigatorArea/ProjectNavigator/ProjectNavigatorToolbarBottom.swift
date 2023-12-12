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

    @State var filter: String = ""
    @State var recentsFilter: Bool = false
    @State var sourceControlFilter: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            addNewFileButton
            PaneTextField(
                "Filter",
                text: $filter,
                leadingAccessories: {
                    FilterDropDownIconButton(menu: {
                        Button {
                            workspace.sortFoldersOnTop.toggle()
                        } label: {
                            Text(workspace.sortFoldersOnTop ? "Alphabetically" : "Folders on top")
                        }
                    }, isOn: !filter.isEmpty)
                    .padding(.leading, 4)
                    .foregroundStyle(
                        filter.isEmpty
                        ? Color(nsColor: .secondaryLabelColor)
                        : Color(nsColor: .controlAccentColor)
                    )
                },
                trailingAccessories: {
                    HStack(spacing: 0) {
                        Toggle(isOn: $recentsFilter) {
                            Image(systemName: "clock")
                        }
                        Toggle(isOn: $sourceControlFilter) {
                            Image(systemName: "plusminus.circle")
                        }
                    }
                    .toggleStyle(.icon(font: .system(size: 14), size: CGSize(width: 18, height: 20)))
                    .padding(.trailing, 2.5)
                },
                clearable: true,
                hasValue: !filter.isEmpty || recentsFilter || sourceControlFilter
            )
            //            .onChange(of: filter, perform: {
            // TODO: Filter Workspace Files
            //                workspace.filter = $0
            //            })
        }
        .padding(.horizontal, 5)
        .frame(height: 28, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    /// Retrieves the active tab URL from the underlying editor instance, if theres no
    /// active tab, fallbacks to the workspace's root directory
    private func activeTabURL() -> URL {
        if let selectedTab = editorManager.activeEditor.selectedTab {
            if selectedTab.isFolder {
                return selectedTab.url
            }

            // If the current active tab belongs to a file, pop the filename from
            // the path URL to retrieve the folder URL
            let activeTabFileURL = selectedTab.url

            if URLComponents(url: activeTabFileURL, resolvingAgainstBaseURL: false) != nil {
                var pathComponents = activeTabFileURL.pathComponents
                pathComponents.removeLast()

                let fileURL = NSURL.fileURL(withPathComponents: pathComponents)! as URL
                return fileURL
            }
        }

        return workspace.workspaceFileManager.unsafelyUnwrapped.folderUrl
    }

    private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
                workspace.workspaceFileManager?.addFile(fileName: "untitled", toFile: rootFile)
            }
            Button("Add Folder") {
                let filePathURL = activeTabURL()
                guard let rootFile = workspace.workspaceFileManager?.getFile(filePathURL.path) else { return }
                workspace.workspaceFileManager?.addFolder(folderName: "untitled", toFile: rootFile)
            }
        } label: {}
        .background {
            Image(systemName: "plus")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearFilterButton: some View {
        Button {
            filter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

struct FilterDropDownIconButton<MenuView: View>: View {
    @Environment(\.controlActiveState)
    private var activeState

    var menu: () -> MenuView

    var isOn: Bool?

    var body: some View {
        Menu { menu() } label: {}
            .background {
                if isOn == true {
                    Image("line.3.horizontal.decrease.chevron.filled")
                        .foregroundStyle(.tint)
                } else {
                    Image("line.3.horizontal.decrease.chevron")
                }
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 26, height: 13)
            .clipShape(.rect(cornerRadius: 6.5))
    }
}
