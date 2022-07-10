//
//  WorkspaceCodeFileEditor.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import CodeFile
import WorkspaceClient
import StatusBar
import Breadcrumbs
import AppPreferences
import UniformTypeIdentifiers

struct WorkspaceCodeFileView: View {
    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @ViewBuilder
    var codeView: some View {
        ZStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                if file.tabID == workspace.selectionState.selectedId {
                    print("Item loaded is: ", file.url)
                }
                return file.tabID == workspace.selectionState.selectedId
            }) {
                if let fileItem = workspace.selectionState.openedCodeFiles[item] {
                    switch fileItem.typeOfFile {
                    case UTType.image:
                        imageFileView(fileItem, for: item)
                    case UTType.text:
                        codeFileView(fileItem, for: item)
                    default:
                        otherFileView(fileItem, for: item)
                    }
                }
            } else {
                Text("No Editor")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 0)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func codeFileView(
        _ codeFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        CodeFileView(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

    @ViewBuilder
    private func imageFileView(
        _ imageFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        VStack(spacing: 0) {
            BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
            Divider()
            ImageFileView(imageFile: imageFile)
        }
    }

    @ViewBuilder
    private func otherFileView(
        _ otherFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        VStack(spacing: 0) {
            BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
            Divider()
            OtherFileView(otherFile)
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
