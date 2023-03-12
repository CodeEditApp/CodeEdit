//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}

func getCurrentWorkspaceDocument(workspace: WorkspaceDocument) -> String {
    return String(String(describing: workspace.fileURL!.absoluteURL).dropFirst(7))
}

var commited: Bool = false

struct SourceControlToolbarBottom: View {

    @State
    private var commitText: String = ""
    var workspace: WorkspaceDocument

    var body: some View {
        HStack(spacing: 0) {
            TextField("Commit message", text: $commitText)
            sourceControlMenu
            SourceControlSearchToolbar()
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var sourceControlMenu: some View {
        Menu {
            Button("Discard Changes...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Stash Changes...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Commit") {
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                if !commitText.isEmpty {
                    commited = true
                    print(shell("cd \(file); git add ."))
                    print(shell("cd \(file); git commit -m '\(commitText)'"))
                } else {
                    print(shell("cd \(file); git add ."))
                    print(shell("cd \(file); git commit -m 'Changes'"))
                }
            }
                .disabled(commitText.isEmpty)
            Button("Push") {
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                print(shell("cd \(file); git push"))
            }
            Button("Create Pull Request") {
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                print(shell("cd \(file); git pull")) // TODO: Handle output
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
    }
}
