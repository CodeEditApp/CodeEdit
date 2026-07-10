//
//  GitCloneButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import CodeEditCore
import SwiftUI
import ShellClient
import WelcomeWindow

struct GitCloneButton: View {

    @State private var showGitClone = false
    @State private var showCheckoutBranchItem: URL?

    let windowManager: WorkspaceWindowManager
    let shellClient: ShellClientProtocol

    var dismissWindow: () -> Void

    var body: some View {
        WelcomeButton(
            iconName: "square.and.arrow.down.on.square",
            title: "Clone Git Repository...",
            action: {
                showGitClone = true
            }
        )
        .sheet(isPresented: $showGitClone) {
            GitCloneView(
                shellClient: shellClient,
                openBranchView: { url in
                    showCheckoutBranchItem = url
                },
                openDocument: { url in
                    windowManager.openDocument(at: url, onCompletion: { dismissWindow() })
                }
            )
        }
        .sheet(item: $showCheckoutBranchItem) { url in
            GitCheckoutBranchView(
                repoLocalPath: url,
                shellClient: shellClient,
                openDocument: { url in
                    windowManager.openDocument(at: url, onCompletion: { dismissWindow() })
                }
            )
        }
    }
}
