//
//  LSPClient.swift
//  
//
//  Created by Pavel Kasila on 16.04.22.
//

import Foundation

/// A LSP client to handle Language Server process
public class LSPClient {
    var exec: URL
    var workspace: URL
    var process: Process

    /// Initialize new LSP client
    /// - Parameters:
    ///   - executable: Executable of the Language Server to be run
    ///   - workspace: Workspace's URL
    ///   - arguments: Additional arguments from `CELSPArguments` in `Info.plist` of the Language Server bundle
    public init(_ executable: URL, workspace: URL, arguments: [String]?) throws {
        self.exec = executable
        self.workspace = workspace
        self.process = try Process.run(executable, arguments: arguments ?? ["--stdio"], terminationHandler: nil)
    }

    /// Close the process
    public func close() {
        self.process.terminate()
    }
}
