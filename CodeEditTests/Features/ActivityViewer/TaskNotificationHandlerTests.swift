//
//  TaskNotificationHandlerTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 21.06.24.
//

import XCTest
@testable import CodeEdit

final class TaskNotificationHandlerTests: XCTestCase {
    var taskNotificationHandler: TaskNotificationHandler!

    override func setUp() {
        super.setUp()
        taskNotificationHandler = TaskNotificationHandler()
    }

    override func tearDown() {
        taskNotificationHandler = nil
        super.tearDown()
    }

    func testCreateTask() {
        let uuid = UUID().uuidString
        let userInfo: [String: Any] = [
            "id": uuid,
            "action": "create",
            "title": "Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.id, uuid)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testCreateTaskWithPriority() {
        let task1: [String: Any] = [
            "id": UUID().uuidString,
            "action": "create",
            "title": "Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: task1)

        let task2: [String: Any] = [
            "id": UUID().uuidString,
            "action": "createWithPriority",
            "title": "Priority Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: task2)

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.title, "Priority Task Title")
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testUpdateTask() {
        let uuid = UUID().uuidString
        let taskInfo: [String: Any] = [
            "id": uuid,
            "action": "create",
            "title": "Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: taskInfo)

        let taskUpdateInfo: [String: Any] = [
            "id": uuid,
            "action": "update",
            "title": "Updated Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: taskUpdateInfo)

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.title, "Updated Task Title")
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testDeleteTask() {
        let uuid = UUID().uuidString
        let createUserInfo: [String: Any] = [
            "id": uuid,
            "action": "create",
            "title": "Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: createUserInfo)
        let deleteUserInfo: [String: Any] = [
            "id": uuid,
            "action": "delete"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: deleteUserInfo)

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskNotificationHandler.notifications.isEmpty)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testDeleteTaskWithDelay() {
        let uuid = UUID().uuidString
        let createUserInfo: [String: Any] = [
            "id": uuid,
            "action": "create",
            "title": "Task Title"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: createUserInfo)
        let deleteUserInfo: [String: Any] = [
            "id": uuid,
            "action": "deleteWithDelay",
            "delay": 0.2
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: deleteUserInfo)

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.taskNotificationHandler.notifications.isEmpty)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.taskNotificationHandler.notifications.isEmpty)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }
}
