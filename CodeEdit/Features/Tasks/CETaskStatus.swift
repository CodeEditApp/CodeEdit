//
//  CETaskStatus.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

/// Enum to represent a task's status
enum CETaskStatus {
    case stopped
    case running
    case failed
    case finished

    var color: Color {
        switch self {
        case .stopped: return Color.gray
        case .running: return Color.orange
        case .failed: return Color.red
        case .finished: return Color.green
        }
    }
}
