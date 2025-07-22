//
//  waitForExpectation.swift
//  CodeEditTests
//
//  Created by Khan Winter on 7/15/25.
//

func waitForExpectation(
    timeout: ContinuousClock.Duration = .seconds(2.0),
    _ expectation: () throws -> Bool,
    onTimeout: () throws -> Void
) async rethrows {
    let start = ContinuousClock.now
    while .now - start < timeout {
        if try expectation() {
            return
        } else {
            await Task.yield()
        }
    }

    try onTimeout()
}
