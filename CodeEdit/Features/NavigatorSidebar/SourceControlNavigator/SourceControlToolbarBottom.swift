//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

// Runs the specified shell command
@discardableResult
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

// Gets the current workspace's path
func getCurrentWorkspaceDocument(workspace: WorkspaceDocument) -> String {
    return String(String(describing: workspace.fileURL!.absoluteURL).dropFirst(7))
}

// Changes to true when the user has an commit the needs to be pushed
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
            Button("Discard Changes") {
                shell("cd \(getCurrentWorkspaceDocument(workspace: workspace)); git reset –hard")
            }
            Button("Stash Changes") {
                shell("cd \(getCurrentWorkspaceDocument(workspace: workspace)); git stash")
            }
            Button("Commit") {
                // TODO: Handle output
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                if !commitText.isEmpty {
                    commited = true
                    shell("cd \(file); git add .")
                    shell("cd \(file); git commit -m \(commitText)")
                } else {
                    commited = true
                    shell("cd \(file); git add .")
                    shell("cd \(file); git commit -m 'Changes'")
                }
            }
                .disabled(commitText.isEmpty)
            Button("Push") {
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                shell("cd \(file); git push")
                commited = false
            }
                .disabled(commitText.isEmpty)
            Button("Create Pull Request") {
                var file = getCurrentWorkspaceDocument(workspace: workspace)
                shell("cd \(file); git pull") // TODO: Properly implement
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
    }
}
