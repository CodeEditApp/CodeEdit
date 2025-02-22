//
//  HistoryInspectorItemView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/23.
//

import SwiftUI
import SwiftGitX

struct HistoryInspectorItemView: View {
    var commit: Commit

    @Binding var selection: Commit?

    private var showPopup: Binding<Bool> {
        Binding<Bool> {
            selection == commit
        } set: { newValue in
            if newValue {
                selection = commit
            } else if selection == commit {
                selection = nil
            }
        }
    }

    var body: some View {
        CommitListItemView(commit: commit, showRef: false)
            .instantPopover(isPresented: showPopup, arrowEdge: .leading) {
                HistoryPopoverView(commit: commit)
            }
    }
}
