//
//  NSHapticFeedbackPerformerMock.swift
//  CodeEditTests
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import Cocoa

final class NSHapticFeedbackPerformerMock: NSObject, NSHapticFeedbackPerformer {

    var invokedPerform = false
    var invokedPerformCount = 0

    func perform(
        _ pattern: NSHapticFeedbackManager.FeedbackPattern,
        performanceTime: NSHapticFeedbackManager.PerformanceTime
    ) {
        invokedPerform = true
        invokedPerformCount += 1
    }
}
