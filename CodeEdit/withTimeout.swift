//
//  TimedOutError.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/8/25.
//

struct TimedOutError: Error, Equatable {}

/// Execute an operation in the current task subject to a timeout.
/// - Warning: This still requires cooperative task cancellation to work correctly. Ensure tasks opt
///            into cooperative cancellation.
/// - Parameters:
///   - duration: The duration to wait until timing out. Uses a continuous clock.
///   - operation: The async operation to perform.
/// - Returns: Returns the result of `operation` if it completed in time.
/// - Throws: Throws ``TimedOutError`` if the timeout expires before `operation` completes.
///   If `operation` throws an error before the timeout expires, that error is propagated to the caller.
public func withTimeout<R>(
    duration: Duration,
    onTimeout: @escaping @Sendable () async throws -> Void = { },
    operation: @escaping @Sendable () async throws -> R
) async throws -> R {
    return try await withThrowingTaskGroup(of: R.self) { group in
        let deadline: ContinuousClock.Instant = .now + duration

        // Start actual work.
        group.addTask {
            return try await operation()
        }
        // Start timeout child task.
        group.addTask {
            if .now < deadline {
                try await Task.sleep(until: deadline) // sleep until the deadline
            }
            try Task.checkCancellation()
            // We’ve reached the timeout.
            try await onTimeout()
            throw TimedOutError()
        }
        // First finished child task wins, cancel the other task.
        defer { group.cancelAll() }
        do {
            let result = try await group.next()!
            return result
        } catch {
            throw error
        }
    }
}
