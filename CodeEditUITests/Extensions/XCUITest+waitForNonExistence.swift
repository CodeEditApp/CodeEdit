//
//  XCUITest+waitForNonExistence.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/7/25.
//

import XCTest

// Backport to Xcode 15, this exists in Xcode 16.

extension XCUIElement {
    /// Waits the specified amount of time for the element’s `exists` property to become `false`.
    /// - Parameter timeout: The amount of time to wait.
    /// - Returns: `false` if the timeout expires without the element coming out of existence.
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        switch XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: self)], timeout: timeout) {
        case .completed:
            return true
        default:
            return false
        }
    }
}
