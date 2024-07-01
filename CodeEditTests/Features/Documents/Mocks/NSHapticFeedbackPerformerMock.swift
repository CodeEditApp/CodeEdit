//
//  NSHapticFeedbackPerformerMock.swift
//  CodeEditTests
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import Cocoa

final class NSHapticFeedbackPerformerMock: NSObject, NSHapticFeedbackPerformer {

    var invokedPerform: Bool {
        invokedPerformCount > 0
    }
    var invokedPerformCount = 0

    func perform(
        _ pattern: NSHapticFeedbackManager.FeedbackPattern,
        performanceTime: NSHapticFeedbackManager.PerformanceTime
    ) {
        invokedPerformCount += 1
    }

    func reset() {
        invokedPerformCount = 0
    }
}
