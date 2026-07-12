//
//  GitClient+Initiate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/16/23.
//

import Foundation

extension GitClient {
    /// Initiate Git repository
    public func initiate() async throws {
        _ = try await run("init")
    }
}
