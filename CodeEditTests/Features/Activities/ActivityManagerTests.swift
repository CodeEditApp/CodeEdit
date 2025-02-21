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

    override func setUp() {
        super.setUp()
        activityManager = ActivityManager()
    }

    override func tearDown() {
        activityManager = nil
        super.tearDown()
    }

    func testCreateTask() {
        let activity = activityManager.post(title: "Task Title")
        XCTAssertEqual(activityManager.activities.first?.id, activity.id)
        XCTAssertEqual(activityManager.activities.first?.title, "Task Title")
    }

    func testCreateTaskWithPriority() {
        let activity1 = activityManager.post(title: "Task Title")
        let activity2 = activityManager.post(
            priority: true,
            title: "Priority Task Title"
        )

        XCTAssertEqual(activityManager.activities.first?.id, activity2.id)
        XCTAssertEqual(activityManager.activities.first?.title, "Priority Task Title")
        XCTAssertEqual(activityManager.activities.last?.id, activity1.id)
    }

    func testUpdateTask() {
        let activity = activityManager.post(title: "Task Title")

        activityManager.update(
            id: activity.id,
            title: "Updated Task Title"
        )

        XCTAssertEqual(activityManager.activities.first?.title, "Updated Task Title")
    }

    func testDeleteTask() {
        let activity = activityManager.post(title: "Task Title")
        activityManager.delete(id: activity.id)

        XCTAssertTrue(activityManager.activities.isEmpty)
    }

    func testDeleteTaskWithDelay() {
        let activity = activityManager.post(title: "Task Title")
        activityManager.delete(id: activity.id, delay: 0.2)

        XCTAssertFalse(activityManager.activities.isEmpty)

        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.activityManager.activities.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
