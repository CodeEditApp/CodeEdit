//
//  StatusBarBranchPicker.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import GitClient
import SwiftUI

internal struct StatusBarBranchPicker: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Menu {
            ForEach((try? model.gitClient.getBranches(false)) ?? [], id: \.self) { branch in
                Button {
                    do {
                        guard model.selectedBranch != branch else { return }
                        try model.gitClient.checkoutBranch(branch)
                        model.selectedBranch = branch
                    } catch {
                        guard let error = error as? GitClient.GitClientError else { return }
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "Ok")
                        switch error {
                        case .notGitRepository:
                            alert.messageText = "Not a git repository"
                        case let .outputError(message):
                            alert.messageText = message
                        }
                        alert.runModal()
                    }
                } label: {
                    Text(branch)
                    // checkout branch
                }
            }
        } label: {
            Text(model.selectedBranch ?? "No Git Repository")
                .font(model.toolbarFont)
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 150)
        .fixedSize(horizontal: true, vertical: true)
        .onHover { isHovering($0) }
        .disabled(model.selectedBranch == nil)
    }
}
