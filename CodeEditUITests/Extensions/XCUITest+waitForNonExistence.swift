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
    ///
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let timeStart = Date().timeIntervalSince1970

        while Date().timeIntervalSince1970 <= (timeStart + timeout) {
            if !exists { return true }
        }

        return false
    }
}
