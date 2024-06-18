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

    var isSh: Bool {
        switch self {
        case .bash, .zsh:
            return true
        }
    }
}
