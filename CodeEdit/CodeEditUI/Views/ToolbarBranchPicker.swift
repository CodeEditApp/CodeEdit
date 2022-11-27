//
//  ToolbarBranchPicker.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 21.04.22.
//

import SwiftUI
import CodeEditSymbols

/// A view that pops up a branch picker.
struct ToolbarBranchPicker: View {
    private var workspace: WorkspaceClient?
    private var gitClient: GitClient?

    @Environment(\.controlActiveState)
    private var controlActive

    @State
    private var isHovering: Bool = false

    @State
    private var displayPopover: Bool = false

    @State
    private var currentBranch: String?

    /// Initializes the ``ToolbarBranchPicker`` with an instance of a `WorkspaceClient`
    /// - Parameter shellClient: An instance of the current `ShellClient`
    /// - Parameter workspace: An instance of the current `WorkspaceClient`
    init(
        shellClient: ShellClient,
        workspace: WorkspaceClient?
    ) {
        self.workspace = workspace
        if let folderURL = workspace?.folderURL() {
            self.gitClient = GitClient(directoryURL: folderURL, shellClient: shellClient)
        }
        self._currentBranch = State(initialValue: try? gitClient?.getCurrentBranchName())
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if currentBranch != nil {
                Image.checkout
                    .font(.title3)
                    .imageScale(.large)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
            } else {
                Image(systemName: "square.dashed.inset.filled")
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
                if let currentBranch = currentBranch {
                    ZStack(alignment: .trailing) {
                        Text(currentBranch)
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
            PopoverView(gitClient: gitClient, currentBranch: $currentBranch)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { (_) in
            currentBranch = try? gitClient?.getCurrentBranchName()
        }
    }

    private var inactiveColor: Color {
        Color(nsColor: .disabledControlTextColor)
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

        @Binding
        var currentBranch: String?

        var body: some View {
            VStack(alignment: .leading) {
                if let currentBranch = currentBranch {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Current Branch")
                        BranchCell(name: currentBranch, active: true) {}
                    }
                }
                if !branchNames.isEmpty {
                    ScrollView {
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
            var name: String
            var active: Bool = false
            var action: () -> Void

            @Environment(\.dismiss)
            private var dismiss

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
                    EffectView.selectionBackground(isHovering)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .onHover { active in
                    isHovering = active
                }
            }
        }

        var branchNames: [String] {
            ((try? gitClient?.getBranches(false)) ?? []).filter { $0 != currentBranch }
        }
    }
}
