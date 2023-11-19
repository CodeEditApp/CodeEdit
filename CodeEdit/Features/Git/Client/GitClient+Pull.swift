//
//  GitClient+Pull.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/18/23.
//

import Foundation

extension GitClient {
    /// Push changes to remote
    func pullFromRemote() async throws {
        var command = "pull"

        let output = try await self.run(command)
    }
}
