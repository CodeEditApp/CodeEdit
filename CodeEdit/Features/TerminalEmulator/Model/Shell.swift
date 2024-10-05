//
//  ShellIntegration.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/1/24.
//

import Foundation

/// Shells supported by CodeEdit
enum Shell: String, CaseIterable {
    case bash
    case zsh

    var url: String {
        switch self {
        case .bash:
            "/bin/bash"
        case .zsh:
            "/bin/zsh"
        }
    }

    var isSh: Bool {
        switch self {
        case .bash, .zsh:
            return true
        }
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
        shell: Shell = .bash,
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

    var defaultPath: String {
        switch self {
        case .bash:
            "/bin/bash"
        case .zsh:
            "/bin/zsh"
        }
    }

    /// Gets the default shell from the current user and returns the string of the shell path.
    ///
    /// If getting the user's shell does not work, defaults to `zsh`,
    static func autoDetectDefaultShell() -> String {
        guard let currentUser = CurrentUser.getCurrentUser() else {
            return Self.zsh.rawValue // macOS defaults to zsh
        }
        return currentUser.shell
    }
}
