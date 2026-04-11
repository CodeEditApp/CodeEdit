//
//  ShellClientProtocol.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import Combine
import Foundation

/// Protocol for executing shell commands.
protocol ShellClientProtocol: Sendable {
    /// Run a command synchronously.
    /// - Parameter args: Arguments passed to the shell.
    /// - Returns: The command output.
    @discardableResult
    func run(_ args: [String]) throws -> String

    /// Run a command with a Combine publisher for live output.
    /// - Parameter args: Arguments passed to the shell.
    /// - Returns: A publisher that emits output lines.
    @discardableResult
    func runLive(_ args: [String]) -> AnyPublisher<String, Never>

    /// Run a command with an async stream for live output.
    /// - Parameter args: Arguments passed to the shell.
    /// - Returns: An async stream that yields output lines.
    func runAsync(_ args: [String]) -> AsyncThrowingStream<String, Error>
}

extension ShellClientProtocol {
    /// Convenience variadic overload for `run`.
    @discardableResult
    func run(_ args: String...) throws -> String {
        try run(args)
    }

    /// Convenience variadic overload for `runLive`.
    @discardableResult
    func runLive(_ args: String...) -> AnyPublisher<String, Never> {
        runLive(args)
    }

    /// Convenience variadic overload for `runAsync`.
    func runAsync(_ args: String...) -> AsyncThrowingStream<String, Error> {
        runAsync(args)
    }
}
