//
//  GitCloneButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import SwiftUI
import WelcomeWindow

struct GitCloneButton: View {

    @State private var showGitClone = false
    @State private var showCheckoutBranchItem: URL?

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
                openBranchView: { url in
                    showCheckoutBranchItem = url
                },
                openDocument: { url in
                    CodeEditDocumentController.shared.openDocument(at: url, onCompletion: { dismissWindow() })
                }
            )
        }
        .sheet(item: $showCheckoutBranchItem) { url in
            GitCheckoutBranchView(
                repoLocalPath: url,
                openDocument: { url in
                    CodeEditDocumentController.shared.openDocument(at: url, onCompletion: { dismissWindow() })
                }
            )
        }
    }
}
