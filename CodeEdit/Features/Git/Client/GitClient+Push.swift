//
//  GitClient+Push.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Push changes to remote
    func pushToRemote(upstream: String? = nil) async throws {
        var command = "push"
        if let upstream {
            command += " --set-upstream origin \(upstream)"
        }

        let output = try await self.run(command)

        if output.contains("rejected") {
            throw GitClientError.outputError(output)
        }
    }
}
