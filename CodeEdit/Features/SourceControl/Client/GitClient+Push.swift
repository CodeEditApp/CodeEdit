//
//  GitClient+Push.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Push changes to remote
    func pushToRemote(remote: String? = nil, branch: String? = nil, setUpstream: Bool? = false ) async throws {
        var command = "push"
        if let remote, let branch {
            if setUpstream == true {
                command += " --set-upstream"
            }
            command += " \(remote) \(branch)"
        }

        let output = try await self.run(command)

        if output.contains("rejected") {
            throw GitClientError.outputError(output)
        }
    }
}
