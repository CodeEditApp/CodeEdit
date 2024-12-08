//
//  Limiter.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/1/24.
//

import Combine
import Foundation

// TODO: Look into improving this API by using async by default so `Task` isn't needed when used.
enum Limiter {
    // Keep track of debounce timers and throttle states
    private static var debounceTimers: [AnyHashable: Timer] = [:]
    private static var throttleLastExecution: [AnyHashable: Date] = [:]

    /// Debounces an action with a specified duration and identifier.
    /// - Parameters:
    ///   - id: A unique identifier for the debounced action.
    ///   - duration: The debounce duration in seconds.
    ///   - action: The action to be executed after the debounce period.
    static func debounce(id: AnyHashable, duration: TimeInterval, action: @escaping () -> Void) {
        // Cancel any existing debounce timer for the given ID
        debounceTimers[id]?.invalidate()
        // Start a new debounce timer for the given ID
        debounceTimers[id] = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            action()
        }
    }
}
