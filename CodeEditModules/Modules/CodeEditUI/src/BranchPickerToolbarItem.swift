//
//  BranchPickerToolbarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 21.04.22.
//

import SwiftUI
import CodeEditSymbols
import WorkspaceClient
import GitClient

public struct BranchPickerToolbarItem: View {

    private var workspace: WorkspaceClient?
    private var gitClient: GitClient?

    public init(_ workspace: WorkspaceClient?) {
        self.workspace = workspace
        if let folderURL = workspace?.folderURL() {
            self.gitClient = GitClient.default(
                directoryURL: folderURL,
                shellClient: .live
            )
        }
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
        .onTapGesture {
            displayPopover.toggle()
        }
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            PopoverView()
        }
    }

    private var title: String {
        workspace?.folderURL()?.lastPathComponent ?? "Empty"
    }

    private var currentBranch: String? {
        try? gitClient?.getCurrentBranchName()
    }

    private struct PopoverView: View {
        var body: some View {
            VStack {
                Text("Current Branch:")
            }
            .padding()
        }
    }
}
