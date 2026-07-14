//
//  CETaskStatus.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

/// Enum to represent a task's status
public enum CETaskStatus {
    /// The task has not been started yet.
    case notRunning
    /// The user suspended the task's process.
    case stopped
    /// The task's process is currently executing.
    case running
    /// The task's process exited with an error.
    case failed
    /// The task's process exited successfully.
    case finished

    /// The color used to represent this status in task indicators throughout the UI.
    public var color: Color {
        switch self {
        case .notRunning: return Color.gray
        case .stopped: return Color.yellow
        case .running: return Color.orange
        case .failed: return Color.red
        case .finished: return Color.green
        }
    }
}
