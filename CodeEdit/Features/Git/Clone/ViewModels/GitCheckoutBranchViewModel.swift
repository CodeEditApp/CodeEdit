//
//  GitCheckoutBranchView.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/17/23.
//

import Foundation

class GitCheckoutBranchViewModel: ObservableObject {
    @Published var selectedBranch: GitBranch?
    @Published var branches: [GitBranch] = []

    let repoPath: URL
    private let gitClient: GitClient

    init(repoPath: URL) {
        self.repoPath = repoPath
        gitClient = .init(directoryURL: repoPath, shellClient: .live())
    }

    func loadBranches() async {
        branches = ((try? await gitClient.getBranches()) ?? [])

        if selectedBranch == nil {
            selectedBranch = branches.first
        }
    }

    func checkoutBranch() async {
        guard let selectedBranch else { return }

        try? await gitClient.checkoutBranch(selectedBranch)
    }
}
