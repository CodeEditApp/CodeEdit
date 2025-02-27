//
//  ActivityManager.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import Foundation
import Combine
import SwiftUI

/// Manages activities for a workspace
@MainActor
final class ActivityManager: ObservableObject {
    /// Currently displayed activities
    @Published private(set) var activities: [CEActivity] = []

    /// Debounce work item for batching updates
    private var updateWorkItems: [String: DispatchWorkItem] = [:]

    /// Posts a new activity
    /// - Parameters:
    ///   - priority: Whether to insert at start of list
    ///   - title: Activity title
    ///   - message: Optional detail message
    ///   - percentage: Optional progress percentage (0-1)
    ///   - isLoading: Whether activity shows loading indicator
    /// - Returns: The created activity
    @discardableResult
    func post(
        priority: Bool = false,
        title: String,
        message: String? = nil,
        percentage: Double? = nil,
        isLoading: Bool = false
    ) -> CEActivity {
        let activity = CEActivity(
            id: UUID().uuidString,
            title: title,
            message: message,
            percentage: percentage,
            isLoading: isLoading
        )

        withAnimation(.easeInOut(duration: 0.3)) {
            if priority {
                activities.insert(activity, at: 0)
            } else {
                activities.append(activity)
            }
        }

        return activity
    }

    /// Updates an existing activity with debouncing
    /// - Parameters:
    ///   - id: ID of activity to update
    ///   - title: New title (optional)
    ///   - message: New message (optional) 
    ///   - percentage: New progress percentage (optional)
    ///   - isLoading: New loading state (optional)
    func update(
        id: String,
        title: String? = nil,
        message: String? = nil,
        percentage: Double? = nil,
        isLoading: Bool? = nil
    ) {
        // Cancel any pending update for this specific activity
        updateWorkItems[id]?.cancel()

        // Create new work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            if let index = self.activities.firstIndex(where: { $0.id == id }) {
                var activity = self.activities[index]

                if let title = title {
                    activity.title = title
                }
                if let message = message {
                    activity.message = message
                }
                if let percentage = percentage {
                    activity.percentage = percentage
                }
                if let isLoading = isLoading {
                    activity.isLoading = isLoading
                }

                withAnimation(.easeInOut(duration: 0.15)) {
                    self.activities[index] = activity
                }
            }

            self.updateWorkItems.removeValue(forKey: id)
        }

        // Store work item and schedule after delay
        updateWorkItems[id] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: workItem)
    }

    /// Deletes an activity
    /// - Parameter id: ID of activity to delete
    func delete(id: String) {
        // Clear any pending updates for this activity
        updateWorkItems[id]?.cancel()
        updateWorkItems.removeValue(forKey: id)

        withAnimation(.easeInOut(duration: 0.3)) {
            activities.removeAll { $0.id == id }
        }
    }

    /// Deletes an activity after a delay
    /// - Parameters:
    ///   - id: ID of activity to delete
    ///   - delay: Time to wait before deleting
    func delete(id: String, delay: TimeInterval) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(delay))
            delete(id: id)
        }
    }
}

extension Notification.Name {
    static let activity = Notification.Name("activity")
}
