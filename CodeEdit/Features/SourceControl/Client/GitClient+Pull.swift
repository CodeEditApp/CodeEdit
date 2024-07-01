//
//  GitClient+Pull.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/18/23.
//

import Foundation

extension GitClient {
    /// Pull changes from remote
    func pullFromRemote(remote: String? = nil, branch: String? = nil, rebase: Bool? = nil) async throws {
        var command = "pull"

        if let remote = remote, let branch = branch {
            command += " \(remote) \(branch)"
        }

        if rebase == true {
            command += " --rebase"
        }

        _ = try await self.run(command)
    }
}
