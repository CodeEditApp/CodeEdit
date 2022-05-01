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
                if let codeFile = workspace.selectionState.openedCodeFiles[item] {
                    CodeFileView(codeFile: codeFile)
                        .safeAreaInset(edge: .top, spacing: 0) {
                            VStack(spacing: 0) {
                                BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                                Divider()
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                // Use the same background material as xcode tab bar style.
                // Only when the tab bar style is set to `xcode`.
                TabBarXcodeBackground()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBar(windowController: windowController, workspace: workspace)
                TabBarBottomDivider()
            }
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
