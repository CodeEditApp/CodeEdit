//
//  FileManager+MakeExecutable.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/14/25.
//

import Foundation

extension FileManager {
    /// Make a given URL executable via POSIX permissions.
    /// Slightly different from `chmod +x`, does not give execute permissions for users besides
    /// the current user.
    /// - Parameter executableURL: The URL of the file to make executable.
    func makeExecutable(_ executableURL: URL) throws {
        let fileAttributes = try FileManager.default.attributesOfItem(
            atPath: executableURL.path(percentEncoded: false)
        )
        guard var permissions = fileAttributes[.posixPermissions] as? UInt16 else { return }
        permissions |= 0b001_000_000 // Execute perms for user, not group, not others
        try FileManager.default.setAttributes(
            [.posixPermissions: permissions],
            ofItemAtPath: executableURL.path(percentEncoded: false)
        )
    }
}
