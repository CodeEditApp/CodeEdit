//
//  ActivityManagerTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 21.06.24.
//

import XCTest
@testable import CodeEdit

final class ActivityManagerTests: XCTestCase {
    var activityManager: ActivityManager!

    override func setUp() async throws {
        try await super.setUp()
        // Initialize on main actor since ActivityManager is main actor-isolated
        await MainActor.run {
            activityManager = ActivityManager()
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            activityManager = nil
        }
        try await super.tearDown()
    }

    func testCreateTask() async {
        await MainActor.run {
            let activity = activityManager.post(title: "Task Title")
            XCTAssertEqual(activityManager.activities.first?.id, activity.id)
            XCTAssertEqual(activityManager.activities.first?.title, "Task Title")
        }
    }

    func testCreateTaskWithPriority() async {
        await MainActor.run {
            let activity1 = activityManager.post(title: "Task Title")
            let activity2 = activityManager.post(
                priority: true,
                title: "Priority Task Title"
            )

            XCTAssertEqual(activityManager.activities.first?.id, activity2.id)
            XCTAssertEqual(activityManager.activities.first?.title, "Priority Task Title")
            XCTAssertEqual(activityManager.activities.last?.id, activity1.id)
        }
    }

    func testUpdateTask() async {
        await MainActor.run {
            let activity = activityManager.post(title: "Task Title")

            activityManager.update(
                id: activity.id,
                title: "Updated Task Title"
            )

            XCTAssertEqual(activityManager.activities.first?.title, "Updated Task Title")
        }
    }

    func testDeleteTask() async {
        await MainActor.run {
            let activity = activityManager.post(title: "Task Title")
            activityManager.delete(id: activity.id)

            XCTAssertTrue(activityManager.activities.isEmpty)
        }
    }

    func testDeleteTaskWithDelay() async throws {
        let expectation = XCTestExpectation()

        await MainActor.run {
            let activity = activityManager.post(title: "Task Title")
            activityManager.delete(id: activity.id, delay: 0.2)

            XCTAssertFalse(activityManager.activities.isEmpty)
        }

        // Wait for deletion
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        await MainActor.run {
            XCTAssertTrue(self.activityManager.activities.isEmpty)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1)
    }
}
