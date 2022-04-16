//
//  LSPClient.swift
//  
//
//  Created by Pavel Kasila on 16.04.22.
//

import Foundation

public class LSPClient {
    var exec: URL
    var workspace: URL
    var process: Process

    public init(_ exec: URL, workspace: URL, arguments: [String]?) throws {
        self.exec = exec
        self.workspace = workspace
        self.process = try Process.run(exec, arguments: arguments ?? ["--stdio"], terminationHandler: nil)
    }

    public func close() {
        self.process.terminate()
    }
}
