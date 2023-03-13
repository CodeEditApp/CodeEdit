//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

// Gets the current workspace's path
func getCurrentWorkspaceDocument(workspace: WorkspaceDocument) -> String {
     return String(String(describing: workspace.fileURL!.absoluteURL).dropFirst(7))
}

struct SourceControlToolbarBottom: View {
    @State private var commitText: String = ""
    @State var push: Bool = false
    @State var presentPopup: Bool = false

    var shellClient: ShellClient = ShellClient()
    var workspace: WorkspaceDocument

    var body: some View {
        HStack(spacing: 0) {
            Menu {
                Button("Discard Changes") {
                    do {
                        try shellClient.run("cd \(getCurrentWorkspaceDocument(workspace: workspace)); git reset –hard")
                    } catch {
                        print("Git Error")
                    }
                }
                Button("Stash Changes") {
                    do {
                        try shellClient.run("cd \(getCurrentWorkspaceDocument(workspace: workspace)); git stash")
                    } catch {
                        print("Git Error")
                    }
                }
                Button("Commit") {
                    // TODO: Handle output
                    var file = getCurrentWorkspaceDocument(workspace: workspace)
                    print(file)
                    presentPopup = true

                    if !commitText.isEmpty {
                        // do {
                            // try shellClient.run("cd \(file); git add .")
                            // try shellClient.run("cd \(file); git commit -m \(commitText)")
                        // } catch {
                        //    print("Git Error")
                        // }
                    } else {
                        // do {
                            // try shellClient.run("cd \(file); git add .")
                            // try shellClient.run("cd \(file); git commit -m 'Changes'")
                        // } catch {
                        //    print("Git Error")
                        // }
                    }
                }.popover(isPresented: $presentPopup, arrowEdge: .bottom) {
                    Text("test")
                      .frame(width: 100, height: 100)
                }
                Button("Push") {
                    var file = getCurrentWorkspaceDocument(workspace: workspace)
                    do {
                        try shellClient.run("cd \(file); git push")
                    } catch {
                        print("Git Error")
                    }
                }
                Button("Create Pull Request") {
                    do {
                        // TODO: Properly implement
                        try shellClient.run("cd \(getCurrentWorkspaceDocument(workspace: workspace)); git pull")
                    } catch {
                        print("Git Error")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }.popover(isPresented: $presentPopup, arrowEdge: .top) {
                Divider()
                    .padding(.bottom, 55.0)
                TextField("Commit Message", text: $commitText)
                    .padding(.bottom, 50.0)
                    .frame(height: 40)
                Divider()
                    .padding(.bottom, 25)
                    .frame(width: 500.0, height: 20.0)
                Toggle("Push to remote: ", isOn: $push)
                    .padding(.leading)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(maxWidth: 30)
            SourceControlSearchToolbar()
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
