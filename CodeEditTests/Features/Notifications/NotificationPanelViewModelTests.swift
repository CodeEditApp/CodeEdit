//
//  NotificationPanelViewModelTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

import XCTest
import CodeEditCore
import Factory
@testable import CodeEdit

final class NotificationPanelViewModelTests: XCTestCase {
    var notificationManager: NotificationManager!
    var viewModel: NotificationPanelViewModel!

    override func setUp() {
        super.setUp()
        // Fresh manager so the view model doesn't preload notifications from earlier tests.
        Container.shared.notificationManager.reset()
        notificationManager = Container.shared.notificationManager()
        viewModel = NotificationPanelViewModel()
    }

    override func tearDown() {
        viewModel = nil
        notificationManager = nil
        Container.shared.notificationManager.reset()
        super.tearDown()
    }

    func testNotificationAddedAppearsInPanel() {
        notificationManager.post(
            iconSymbol: "bell",
            title: "Test Notification",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.activeNotifications.first?.title, "Test Notification")
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testNotificationDismissedRemovedFromPanel() {
        notificationManager.post(
            iconSymbol: "bell",
            title: "Test Notification",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let notification = self.notificationManager.notifications.first else {
                XCTFail("Notification was never added to the manager")
                testExpectation.fulfill()
                return
            }
            self.notificationManager.dismissNotification(notification)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertTrue(self.viewModel.activeNotifications.isEmpty)
                XCTAssertTrue(self.notificationManager.notifications.isEmpty)
                testExpectation.fulfill()
            }
        }
        wait(for: [testExpectation], timeout: 2)
    }
}
