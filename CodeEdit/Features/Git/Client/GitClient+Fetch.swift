//
//  GitClient+Fetch.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/18/23.
//

import Foundation

extension GitClient {
    /// Push changes to remote
    func fetchFromRemote() async throws {
        let command = "fetch"

        _ = try await self.run(command)
    }
}
