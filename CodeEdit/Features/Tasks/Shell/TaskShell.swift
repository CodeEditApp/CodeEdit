//
//  Shell.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import Foundation

// name shell already taken...
public enum TaskShell: String {
    case bash = "/bin/bash"
    case zsh = "/bin/zsh"
    // swiftlint:disable:next identifier_name
    case sh = "/bin/sh"
    case csh = "/bin/csh"
    case tcsh = "/bin/tcsh"
    case ksh = "/bin/ksh"

    var url: String {
        return self.rawValue
    }

    /// Executes a shell command using a specified shell, with optional environment variables.
    ///
    /// - Parameters:
    ///   - process: The `Process` instance to be configured and run.
    ///   - command: The shell command to execute.
    ///   - environmentVariables: A dictionary of environment variables to set for the process. Default is `nil`.
    ///   - shell: The shell to use for executing the command. Default is `.bash`.
    ///   - outputPipe: The `Pipe` instance to capture standard output and standard error.
    /// - Throws: An error if the process fails to run.
    ///
    /// ### Example
    /// ```swift
    /// let process = Process()
    /// let outputPipe = Pipe()
    /// try executeCommandWithShell(
    ///     process: process,
    ///     command: "echo 'Hello, World!'",
    ///     environmentVariables: ["PATH": "/usr/bin"],
    ///     shell: .bash,
    ///     outputPipe: outputPipe
    /// )
    /// let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    /// let outputString = String(data: outputData, encoding: .utf8)
    /// print(outputString) // Output: "Hello, World!"
    /// ```
    public static func executeCommandWithShell(
        process: Process,
        command: String,
        environmentVariables: [String: String]? = nil,
        shell: TaskShell = .bash,
        outputPipe: Pipe
    ) throws {
        // Setup envs'
        process.environment = environmentVariables
        // Set the executable to bash
        process.executableURL = URL(fileURLWithPath: shell.url)

        // Pass the command as an argument
        // `--login` argument is needed when using a shell with a process in Swift to ensure
        // that the shell loads the user's profile settings (like .bash_profile or .profile),
        // which configure the environment variables and other shell settings.
        process.arguments = ["--login", "-c", command]

        process.standardOutput = outputPipe
        process.standardError = outputPipe

        // Run the process
        try process.run()
    }
}
