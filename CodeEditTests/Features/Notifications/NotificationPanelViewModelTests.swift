//
//  NotificationPanelViewModelTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

import XCTest
import CodeEditCore
@testable import CENotifications
@testable import CodeEdit

@MainActor
final class NotificationPanelViewModelTests: XCTestCase {
    var eventBus: EventBus!
    var notificationManager: (any NotificationManaging)!
    var viewModel: NotificationPanelViewModel!

    override func setUp() {
        super.setUp()
        // Fresh manager and bus so the view model doesn't preload notifications from earlier tests.
        // Manager and view model must share one bus: posts flow manager → bus → view model.
        eventBus = EventBus()
        notificationManager = NotificationManager(eventBus: eventBus)
        viewModel = NotificationPanelViewModel(notificationManager: notificationManager, eventBus: eventBus)
    }

    override func tearDown() {
        viewModel = nil
        notificationManager = nil
        eventBus = nil
        super.tearDown()
    }

    func testNotificationAddedAppearsInPanel() async throws {
        notificationManager.post(
            iconSymbol: "bell",
            title: "Test Notification",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )

        // Allow the Combine republish from manager to view model to propagate.
        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(viewModel.activeNotifications.first?.title, "Test Notification")
    }

    func testNotificationDismissedRemovedFromPanel() async throws {
        notificationManager.post(
            iconSymbol: "bell",
            title: "Test Notification",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )

        try await Task.sleep(for: .milliseconds(200))

        let notification = try XCTUnwrap(
            notificationManager.notifications.first,
            "Notification was never added to the manager"
        )
        notificationManager.dismissNotification(notification)

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertTrue(viewModel.activeNotifications.isEmpty)
        XCTAssertTrue(notificationManager.notifications.isEmpty)
    }

    func testUnreadCountRepublishedToViewModel() async throws {
        notificationManager.post(
            iconSymbol: "bell",
            title: "First",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )
        notificationManager.post(
            iconSymbol: "bell",
            title: "Second",
            description: "A notification for testing",
            actionButtonTitle: "OK",
            action: {}
        )

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(viewModel.unreadCount, 2)

        let notification = try XCTUnwrap(
            notificationManager.notifications.first,
            "Notifications were never added to the manager"
        )
        notificationManager.markAsRead(notification)

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(viewModel.unreadCount, 1)
    }
}
