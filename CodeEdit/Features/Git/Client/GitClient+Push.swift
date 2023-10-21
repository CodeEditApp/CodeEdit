//
//  GitClient+Push.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Push changes to remote
    func push(upstream: String? = nil) async throws {
        var command = "push"
        if let upstream {
            command += " --set-upstream origin \(upstream)"
        }

        _ = try await self.run(command)
    }
}
