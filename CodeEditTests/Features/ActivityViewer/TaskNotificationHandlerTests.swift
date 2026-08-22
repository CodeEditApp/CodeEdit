//
//  TaskNotificationHandlerTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 21.06.24.
//

import XCTest
import CodeEditCore
@testable import CodeEdit

final class TaskNotificationHandlerTests: XCTestCase {
    var taskNotificationHandler: TaskNotificationHandler!
    var eventBus: EventBus!

    override func setUp() {
        super.setUp()
        eventBus = EventBus()
        taskNotificationHandler = TaskNotificationHandler(eventBus: eventBus)
    }

    override func tearDown() {
        taskNotificationHandler = nil
        eventBus = nil
        super.tearDown()
    }

    func testCreateTask() {
        let uuid = UUID().uuidString
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: uuid, title: "Task Title"))
        ))

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.id, uuid)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testCreateTaskWithPriority() {
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: UUID().uuidString, title: "Task Title"))
        ))
        eventBus.publish(TaskNotificationEvent(
            .createWithPriority(TaskNotificationModel(id: UUID().uuidString, title: "Priority Task Title"))
        ))

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.title, "Priority Task Title")
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testUpdateTask() {
        let uuid = UUID().uuidString
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: uuid, title: "Task Title"))
        ))
        eventBus.publish(TaskNotificationEvent(
            .update(id: uuid, title: "Updated Task Title")
        ))

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskNotificationHandler.notifications.first?.title, "Updated Task Title")
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testDeleteTask() {
        let uuid = UUID().uuidString
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: uuid, title: "Task Title"))
        ))
        eventBus.publish(TaskNotificationEvent(.delete(id: uuid)))

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskNotificationHandler.notifications.isEmpty)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testDeleteTaskWithDelay() {
        let uuid = UUID().uuidString
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: uuid, title: "Task Title"))
        ))
        eventBus.publish(TaskNotificationEvent(.deleteWithDelay(id: uuid, delay: 0.2)))

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

    func testEventForOtherWorkspaceIsIgnored() {
        let uuid = UUID().uuidString
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: uuid, title: "Task Title")),
            workspace: URL(fileURLWithPath: "/some/other/workspace")
        ))

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskNotificationHandler.notifications.isEmpty)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }
}
