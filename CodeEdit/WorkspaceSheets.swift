//
//  WorkspaceSheets.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/1/24.
//

import SwiftUI
import CodeEditCore

struct WorkspaceSheets: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @EnvironmentObject var sourceControlViewModel: SourceControlViewModel

    var body: some View {
        EmptyView()
            .sheet(isPresented: Binding<Bool>(
                get: { sourceControlViewModel.pushSheetIsPresented &&
                       !sourceControlViewModel.addExistingRemoteSheetIsPresented },
                set: { sourceControlViewModel.pushSheetIsPresented = $0 }
            )) {
                SourceControlPushView()
            }
            .sheet(isPresented: Binding<Bool>(
                get: { sourceControlViewModel.pullSheetIsPresented &&
                       !sourceControlViewModel.addExistingRemoteSheetIsPresented &&
                       !sourceControlViewModel.stashSheetIsPresented },
                set: { sourceControlViewModel.pullSheetIsPresented = $0 }
            )) {
                if sourceControlViewModel.addExistingRemoteSheetIsPresented == true {
                    SourceControlAddExistingRemoteView()
                } else {
                    SourceControlPullView()
                }
            }
            .sheet(isPresented: $sourceControlViewModel.fetchSheetIsPresented) {
                SourceControlFetchView()
            }
            .sheet(isPresented: $sourceControlViewModel.stashSheetIsPresented) {
                SourceControlStashView()
            }
            .sheet(isPresented: $sourceControlViewModel.addExistingRemoteSheetIsPresented) {
                SourceControlAddExistingRemoteView()
            }
            .sheet(item: Binding<GitBranch?>(
                get: {
                    sourceControlViewModel.switchToBranch != nil
                    && sourceControlViewModel.stashSheetIsPresented
                    ? nil
                    : sourceControlViewModel.switchToBranch
                },
                set: { sourceControlViewModel.switchToBranch = $0 }
            )) { branch in
                SourceControlSwitchView(branch: branch)
            }
            .alert(isPresented: $sourceControlViewModel.discardAllAlertIsPresented) {
                Alert(
                    title: Text("Do you want to discard all uncommitted, local changes?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Discard")) {
                        sourceControlManager.discardAllChanges()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Cannot Stage Changes", isPresented: $sourceControlViewModel.noChangesToStageAlertIsPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There are no uncommitted changes in the local repository for this project.")
            }
            .alert("Cannot Unstage Changes", isPresented: $sourceControlViewModel.noChangesToUnstageAlertIsPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There are no uncommitted changes in the local repository for this project.")
            }
            .alert("Cannot Stash Changes", isPresented: $sourceControlViewModel.noChangesToStashAlertIsPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There are no uncommitted changes in the local repository for this project.")
            }
            .alert("Cannot Discard Changes", isPresented: $sourceControlViewModel.noChangesToDiscardAlertIsPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There are no uncommitted changes in the local repository for this project.")
            }
    }
}
