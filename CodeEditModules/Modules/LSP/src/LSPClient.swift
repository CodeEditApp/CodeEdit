//
//  LSPClient.swift
//  CodeEditModules/LSP
//
//  Created by Pavel Kasila on 16.04.22.
//

import Foundation

/// A LSP client to handle Language Server process
public final class LSPClient {
    private let executable: URL
    private let workspace: URL
    private let process: Process

    /// Initialize new LSP client
    /// - Parameters:
    ///   - executable: Executable of the Language Server to be run
    ///   - workspace: Workspace's URL
    ///   - arguments: Additional arguments from `CELSPArguments` in `Info.plist` of the Language Server bundle
    public init(_ executable: URL, workspace: URL, arguments: [String]?) throws {
        self.executable = executable
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: executable.path)
        self.workspace = workspace
        self.process = try Process.run(executable, arguments: arguments ?? ["--stdio"], terminationHandler: nil)
    }

    /// Close the process
    public func close() {
        process.terminate()
    }
}
