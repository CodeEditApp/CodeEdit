//
//  GitClient+Pull.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/18/23.
//

import Foundation

extension GitClient {
    /// Pull changes from remote
    func pullFromRemote() async throws {
        let command = "pull"

        _ = try await self.run(command)
    }
}
