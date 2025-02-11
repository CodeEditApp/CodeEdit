import SwiftUI
import Combine
import UserNotifications

final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var notifications: [CENotification] = []
    @Published private(set) var activeNotification: CENotification?

    private var timer: Timer?
    private let displayDuration: TimeInterval = 5.0
    private var isPaused: Bool = false
    private var isAppActive: Bool = true

    private override init() {
        super.init()

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Set up notification center delegate
        UNUserNotificationCenter.current().delegate = self

        // Observe app active state
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc
    private func applicationDidBecomeActive() {
        isAppActive = true
    }

    @objc
    private func applicationDidResignActive() {
        isAppActive = false
    }

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var hasActiveNotification: Bool {
        activeNotification != nil
    }

    func post(
        icon: String,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        let notification = CENotification(
            icon: icon,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky
        )

        DispatchQueue.main.async { [weak self] in
            self?.notifications.append(notification)

            if self?.isAppActive == true {
                self?.showTemporaryNotification(notification)
            } else {
                self?.showSystemNotification(notification)
            }
        }
    }

    private func showSystemNotification(_ notification: CENotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.description
        content.userInfo = ["id": notification.id.uuidString]

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func showTemporaryNotification(_ notification: CENotification) {
        activeNotification = notification

        guard !notification.isSticky else { return }

        startHideTimer()
    }

    private func startHideTimer() {
        timer?.invalidate()
        timer = nil

        guard !isPaused else { return }

        timer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak self] _ in
            self?.hideActiveNotification()
        }
    }

    func pauseTimer() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resumeTimer() {
        isPaused = false
        if activeNotification != nil && !activeNotification!.isSticky {
            startHideTimer()
        }
    }

    func hideActiveNotification() {
        activeNotification = nil
        timer?.invalidate()
        timer = nil
    }

    func dismissNotification(_ notification: CENotification) {
        if activeNotification?.id == notification.id {
            hideActiveNotification()
        }
        notifications.removeAll(where: { $0.id == notification.id })
    }

    func markAsRead(_ notification: CENotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    func handleSystemNotificationResponse(id: String) {
        if let uuid = UUID(uuidString: id),
           let notification = notifications.first(where: { $0.id == uuid }) {
            notification.action()
            dismissNotification(notification)
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let id = response.notification.request.content.userInfo["id"] as? String {
            DispatchQueue.main.async {
                self.handleSystemNotificationResponse(id: id)
            }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Don't show system notifications when app is active
        completionHandler([])
    }
}
