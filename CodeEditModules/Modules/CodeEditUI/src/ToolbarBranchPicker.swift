//
//  ToolbarBranchPicker.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 21.04.22.
//

import SwiftUI
import CodeEditSymbols
import WorkspaceClient
import GitClient

/// A view that pops up a branch picker.
public struct ToolbarBranchPicker: View {

    private var workspace: WorkspaceClient?

    private var gitClient: GitClient?

    @State private var currentBranch: String?

    /// Initializes the ``ToolbarBranchPicker`` with an instance of a `WorkspaceClient`
    /// - Parameter workspace: An instance of the current `WorkspaceClient`
    public init(_ workspace: WorkspaceClient?) {
        self.workspace = workspace
        if let folderURL = workspace?.folderURL() {
            self.gitClient = GitClient.default(
                directoryURL: folderURL,
                shellClient: .live
            )
        }
        self._currentBranch = State(initialValue: try? gitClient?.getCurrentBranchName())
    }

    @State
    private var isHovering: Bool = false

    @State
    private var displayPopover: Bool = false

    public var body: some View {
        HStack(alignment: .center) {
            Image.checkout
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(height: 16)
                    .help(title)
                if let currentBranch = currentBranch {
                    ZStack(alignment: .trailing) {
                        Text(currentBranch)
                            .padding(.trailing)
                        if isHovering {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 11)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            displayPopover.toggle()
        }
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            PopoverView(gitClient: gitClient, currentBranch: $currentBranch)
        }
    }

    private var title: String {
        workspace?.folderURL()?.lastPathComponent ?? "Empty"
    }

    // MARK: Popover View

    /// A popover view that appears once the branch picker is tapped.
    ///
    /// It displays the currently checked-out branch and all other local branches.
    private struct PopoverView: View {

        var gitClient: GitClient?

        @Binding var currentBranch: String?

        var body: some View {
            VStack(alignment: .leading) {
                if let currentBranch = currentBranch {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Current Branch")
                        BranchCell(name: currentBranch, active: true) {}
                    }
                }
                if !branchNames.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Branches")
                        ForEach(branchNames, id: \.self) { branch in
                            BranchCell(name: branch) {
                                try? gitClient?.checkoutBranch(branch)
                                currentBranch = try? gitClient?.getCurrentBranchName()
                            }
                        }
                    }
                }
            }
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
            @Environment(\.dismiss) private var dismiss

            var name: String
            var active: Bool = false
            var action: () -> Void

            @State
            private var isHovering: Bool = false

            var body: some View {
                Button {
                    action()
                    dismiss()
                } label: {
                    HStack {
                        Label {
                            Text(name)
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
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(
                            isHovering ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.8) : .clear
                        )
                )
                .onHover { active in
                    isHovering = active
                }
            }
        }

        var branchNames: [String] {
            (try? gitClient?.getBranches(false)) ?? []
        }
    }
}
