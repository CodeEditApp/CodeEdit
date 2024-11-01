//
//  Limiter.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/1/24.
//

import Combine
import Foundation

enum Limiter {
    // Keep track of debounce timers and throttle states
    private static var debounceTimers: [AnyHashable: AnyCancellable] = [:]
    private static var throttleLastExecution: [AnyHashable: Date] = [:]

    /// Debounces an action with a specified duration and identifier.
    /// - Parameters:
    ///   - id: A unique identifier for the debounced action.
    ///   - duration: The debounce duration in seconds.
    ///   - action: The action to be executed after the debounce period.
    static func debounce(id: AnyHashable, duration: TimeInterval, action: @escaping () -> Void) {
        // Cancel any existing debounce timer for the given ID
        debounceTimers[id]?.cancel()

        // Start a new debounce timer for the given ID
        debounceTimers[id] = Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { _ in
                action()
                debounceTimers[id] = nil
            }
    }

    /// Throttles an action with a specified duration and identifier.
    /// - Parameters:
    ///   - id: A unique identifier for the throttled action.
    ///   - duration: The throttle duration in seconds.
    ///   - action: The action to be executed after the throttle period.
    static func throttle(id: AnyHashable, duration: TimeInterval, action: @escaping () -> Void) {
        // Check the time of the last execution for the given ID
        if let lastExecution = throttleLastExecution[id], Date().timeIntervalSince(lastExecution) < duration {
            return // Skip this call if it's within the throttle duration
        }

        // Update the last execution time and perform the action
        throttleLastExecution[id] = Date()
        action()
    }
}
