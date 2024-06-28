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

    public static func executeCommandWithShell(
        process: Process,
        command: String,
        shell: TaskShell = .bash,
        outputPipe: Pipe
    ) throws {
        // Set the executable to bash
        process.executableURL = URL(fileURLWithPath: shell.url)
        // Pass the command as an argument to bash
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
