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

    var defaultPath: String {
        switch self {
        case .bash:
            "/bin/bash"
        case .zsh:
            "/bin/zsh"
        }
    }

    /// Create the exec arguments for a new shell with the given behavior.
    /// - Parameters:
    ///   - interactive: The shell is interactive, accepts user input.
    ///   - login: A login shell.
    /// - Returns: The argument string.
    func execArguments(interactive: Bool, login: Bool) -> String? {
        var args = ""

        switch self {
        case .bash, .zsh:
            if interactive {
                args.append("i")
            }

            if login {
                args.append("l")
            }
        }

        return args.isEmpty ? nil : "-" + args
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
