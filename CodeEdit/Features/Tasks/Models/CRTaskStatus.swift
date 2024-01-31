//
//  TaskStatus.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/2/24.
//

import SwiftUI

/// Enum to represent a task's status
enum CETaskStatus {
    case running
    case stopped
    case failed
    case finished

    var color: Color {
        switch self {
        case .running: return Color.orange
        case .stopped: return Color.gray
        case .failed: return Color.red
        case .finished: return Color.green
        }
    }
}
