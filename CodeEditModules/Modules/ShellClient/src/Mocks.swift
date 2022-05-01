//
//  Mocks.swift
//  CodeEditModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//

public extension ShellClient {
    static func always(_ output: String) -> Self {
        ShellClient { _ in
            output
        }
    }
}
