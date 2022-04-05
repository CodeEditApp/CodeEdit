//
//  Interface.swift
//
//
//  Created by Marco Carnevali on 27/03/22.
//

public struct ShellClient {
    public var run: (_ command: String) throws -> String

    public init(
        run: @escaping (_ command: String) throws -> String
    ) {
        self.run = run
    }
}
