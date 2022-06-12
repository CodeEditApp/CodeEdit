//
//  Interface.swift
//  CodeEditModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//
import Combine

// TODO: DOCS (Marco Carnevali)
// swiftlint:disable missing_docs
public struct ShellClient {
    public var runLive: (_ args: String...) -> AnyPublisher<String, Never>
    public var run: (_ args: String...) throws -> String

    public init(
        runLive: @escaping (_ args: String...) -> AnyPublisher<String, Never>,
        run: @escaping (_ args: String...) throws -> String
    ) {
        self.runLive = runLive
        self.run = run
    }
}
