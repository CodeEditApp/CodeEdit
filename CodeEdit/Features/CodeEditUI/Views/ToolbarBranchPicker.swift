//
//  ToolbarBranchPicker.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 21.04.22.
//

import SwiftUI
import CodeEditSymbols
import Combine

/// A view that pops up a branch picker.
struct ToolbarBranchPicker: View {
    private var workspaceFileManager: CEWorkspaceFileManager?
    private var sourceControlManager: SourceControlManager?

    @Environment(\.controlActiveState)
    private var controlActive

    @State private var isHovering: Bool = false
    @State private var displayPopover: Bool = false
    @State private var currentBranch: GitBranch?

    /// Initializes the ``ToolbarBranchPicker`` with an instance of a `WorkspaceClient`
    /// - Parameter workspace: An instance of the current `WorkspaceClient`
    init(
        workspaceFileManager: CEWorkspaceFileManager?
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.sourceControlManager = workspaceFileManager?.sourceControlManager
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if currentBranch != nil {
                Image.checkout
                    .font(.title3)
                    .imageScale(.large)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
            } else {
                Image(systemName: "folder.fill.badge.gearshape")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                    .frame(height: 16)
                    .help(title)
                if let currentBranch {
                    ZStack(alignment: .trailing) {
                        Text(currentBranch.name)
                            .padding(.trailing)
                        if isHovering {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .secondary)
                    .frame(height: 11)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if currentBranch != nil {
                displayPopover.toggle()
            }
        }
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            if let sourceControlManager = workspaceFileManager?.sourceControlManager {
                PopoverView(sourceControlManager: sourceControlManager)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { (_) in
            Task {
                await sourceControlManager?.refreshCurrentBranch()
            }
        }
        .onReceive(
            self.sourceControlManager?.$currentBranch.eraseToAnyPublisher() ??
            Empty().eraseToAnyPublisher()
        ) { branch in
            self.currentBranch = branch
        }
        .task {
            await self.sourceControlManager?.refreshCurrentBranch()
        }
    }

    private var inactiveColor: Color {
        Color(nsColor: .disabledControlTextColor)
    }

    private var title: String {
        workspaceFileManager?.folderUrl.lastPathComponent ?? "Empty"
    }

    // MARK: Popover View

    /// A popover view that appears once the branch picker is tapped.
    ///
    /// It displays the currently checked-out branch and all other local branches.
    private struct PopoverView: View {
        @ObservedObject var sourceControlManager: SourceControlManager

        var body: some View {
            VStack(alignment: .leading) {
                if let currentBranch = sourceControlManager.currentBranch {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Current Branch")
                        BranchCell(sourceControlManager: sourceControlManager, branch: currentBranch, active: true)
                    }
                }

                let branches = sourceControlManager.branches
                    .filter({ $0.isLocal && $0 != sourceControlManager.currentBranch })
                if !branches.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Branches")
                        ForEach(branches, id: \.self) { branch in
                            BranchCell(sourceControlManager: sourceControlManager, branch: branch)
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(5)
            .frame(width: 340)
            .task {
                await sourceControlManager.refreshBranches()
            }
        }

        func headerLabel(_ title: String) -> some View {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 5)
        }

        // MARK: Branch Cell

        /// A Button Cell that represents a branch in the branch picker
        struct BranchCell: View {
            let sourceControlManager: SourceControlManager
            var branch: GitBranch
            var active: Bool = false

            @Environment(\.dismiss)
            private var dismiss

            @State private var isHovering: Bool = false

            var body: some View {
                Button {
                    switchBranch()
                } label: {
                    HStack {
                        Label {
                            Text(branch.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            Image.checkout
                                .imageScale(.large)
                        }
                        .foregroundColor(isHovering ? .white : .secondary)
                        if active {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(isHovering ? .white : .green)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    EffectView.selectionBackground(isHovering)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .onHover { active in
                    isHovering = active
                }
            }

            func switchBranch() {
                Task {
                    do {
                        try await sourceControlManager.checkoutBranch(branch: branch)
                        await MainActor.run {
                            dismiss()
                        }
                    } catch {
                        await sourceControlManager.showAlertForError(title: "Failed to checkout", error: error)
                    }
                }
            }
        }
    }
}
