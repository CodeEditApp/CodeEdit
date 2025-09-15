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
    private weak var workspaceFileManager: CEWorkspaceFileManager?
    private weak var sourceControlManager: SourceControlManager?

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
        HStack(alignment: .center, spacing: 7) {
            Group {
                if currentBranch != nil {
                    Image(symbol: "branch")
                } else {
                    Image(systemName: "folder.fill.badge.gearshape")
                }
            }
            .foregroundColor(controlActive == .inactive ? inactiveColor : .secondary)
            .font(.system(size: 14))
            .imageScale(.medium)
            .frame(width: 17, height: 17)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                    .frame(height: 16)
                    .help(title)
                if let currentBranch {
                    Menu(content: {
                        if let sourceControlManager = workspaceFileManager?.sourceControlManager {
                            PopoverView(sourceControlManager: sourceControlManager)
                        }
                    }, label: {
                        Text(currentBranch.name)
                            .font(.subheadline)
                            .foregroundColor(controlActive == .inactive ? inactiveColor : .gray)
                            .frame(height: 11)
                    })
                    .menuIndicator(isHovering ? .visible : .hidden)
                    .buttonStyle(.borderless)
                    .padding(.leading, -3)
                    .padding(.bottom, 2)
                }
            }
        }
        .onHover { active in
            isHovering = active
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { (_) in
            if self.currentBranch != nil {
                Task {
                    await sourceControlManager?.refreshCurrentBranch()
                }
            }
        }
        .onReceive(
            self.sourceControlManager?.$currentBranch.eraseToAnyPublisher() ??
            Empty().eraseToAnyPublisher()
        ) { branch in
            self.currentBranch = branch
        }
        .task {
            if Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled {
                await self.sourceControlManager?.refreshCurrentBranch()
                await self.sourceControlManager?.refreshBranches()
            }
        }
        .if(.tahoe) {
            $0.padding(.leading, 10).frame(minWidth: 140)
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
                    Section {
                        headerLabel("Current Branch")
                        BranchCell(sourceControlManager: sourceControlManager, branch: currentBranch, active: true)
                    }
                }

                let branches = sourceControlManager.orderedLocalBranches
                    .filter({ $0 != sourceControlManager.currentBranch })
                let branchesGroups = branches.reduce(into: [String: GitBranchesGroup]()) { result, branch in
                    guard let branchPrefix = branch.name.components(separatedBy: "/").first else {
                        return
                    }

                    result[
                        branchPrefix.lowercased(),
                        default: GitBranchesGroup(name: branchPrefix, branches: [])
                    ].branches.append(branch)
                }

                if !branches.isEmpty {
                    Section {
                        headerLabel("Branches")
                        ForEach(branchesGroups.keys.sorted(), id: \.self) { branchGroupPrefix in
                            if let group = branchesGroups[branchGroupPrefix] {
                                if !group.shouldNest {
                                    BranchCell(
                                        sourceControlManager: sourceControlManager,
                                        branch: group.branches.first!
                                    )
                                } else {
                                    Menu(content: {
                                        ForEach(group.branches, id: \.self) { branch in
                                            BranchCell(
                                                sourceControlManager: sourceControlManager,
                                                branch: branch,
                                                title: String(
                                                    branch.name.suffix(branch.name.count - branchGroupPrefix.count - 1)
                                                )
                                            )
                                        }
                                    }, label: {
                                        HStack {
                                            Image(systemName: "folder")
                                            Text(group.name)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(5)
            .frame(width: 340)
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
            let branch: GitBranch
            let active: Bool
            let title: String?

            init(
                sourceControlManager: SourceControlManager,
                branch: GitBranch,
                active: Bool = false,
                title: String? = nil
            ) {
                self.sourceControlManager = sourceControlManager
                self.branch = branch
                self.active = active
                self.title = title
            }

            var body: some View {
                Button {
                    switchBranch()
                } label: {
                    HStack {
                        if active {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image.branch
                        }
                        Text(self.title ?? branch.name)
                    }
                }
            }

            func switchBranch() {
                Task {
                    do {
                        try await sourceControlManager.checkoutBranch(branch: branch)
                    } catch {
                        await sourceControlManager.showAlertForError(title: "Failed to checkout", error: error)
                    }
                }
            }
        }
    }
}
