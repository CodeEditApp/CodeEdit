//
//  InstallStepConfirmation.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

/// Whether a package installation step requires the user's confirmation before it executes.
public enum InstallStepConfirmation {
    /// No confirmation is needed; the step can run immediately.
    case none
    /// The user must approve the step before it runs; `message` describes what will happen.
    case required(message: String)
}
