//
//  CheckoutBranch.swift
//  CodeEditModules/Git
//
//  Created by Aleksi Puttonen on 18.4.2022.
//

import Foundation
import SwiftUI

// TODO: DOCS (Aleksi Puttonen)
extension CheckoutBranchView {
    func getBranches() -> [String] {
        guard let url = URL(string: repoPath) else {
            return [""]
        }
        do {
            let branches = try GitClient(directoryURL: url,
                                                 shellClient: shellClient).getBranches(true)
            return branches
        } catch {
            return [""]
        }
    }
    func checkoutBranch() {
        var parsedBranch = selectedBranch
        if selectedBranch.contains("origin/") || selectedBranch.contains("upstream/") {
            parsedBranch = selectedBranch.components(separatedBy: "/")[1]
        }
        do {
            if let url = URL(string: repoPath) {
                try GitClient(directoryURL: url, shellClient: shellClient).checkoutBranch(parsedBranch)
                isPresented = false
            }
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
            case .failedToDecodeURL:
                alert.messageText = "Failed to decode URL"
            }
            alert.runModal()
        }
    }
}
