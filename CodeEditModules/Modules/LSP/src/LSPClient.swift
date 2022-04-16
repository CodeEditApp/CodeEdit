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

    public init(_ exec: URL, workspace: URL) {
        self.exec = exec
        self.workspace = workspace
    }
}
