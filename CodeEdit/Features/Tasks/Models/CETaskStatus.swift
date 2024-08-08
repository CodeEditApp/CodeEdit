//
//  CETaskStatus.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

/// Enum to represent a task's status
enum CETaskStatus {
    // default state
    case notRunning
    // User suspended the process
    case stopped
    case running
    // Processes finished with an error
    case failed
    // Processes finished without an error
    case finished

    var color: Color {
        switch self {
        case .notRunning: return Color.gray
        case .stopped: return Color.yellow
        case .running: return Color.orange
        case .failed: return Color.red
        case .finished: return Color.green
        }
    }
}
