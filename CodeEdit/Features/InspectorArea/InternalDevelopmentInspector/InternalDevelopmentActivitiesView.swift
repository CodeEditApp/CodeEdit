//
//  InternalDevelopmentActivitiesView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/20/25.
//

import SwiftUI

struct InternalDevelopmentActivitiesView: View {
    @EnvironmentObject var activityManager: ActivityManager

    @State private var activityTitle: String = "Test Activity"
    @State private var activityMessage: String = "This is a test activity."
    @State private var activityProgress: Double = 0.0
    @State private var isLoading: Bool = false
    @State private var isPriority: Bool = false
    @State private var autoDelete: Bool = false
    @State private var deleteDelay: Double = 3.0

    // New state for progress timer
    @State private var isProgressTimerRunning: Bool = false
    @State private var progressActivity: CEActivity?

    var body: some View {
        Section("Activities") {
            Toggle("Priority", isOn: $isPriority)
            Toggle("Loading", isOn: $isLoading)

            TextField("Title", text: $activityTitle)
            TextField("Message", text: $activityMessage, axis: .vertical)
                .lineLimit(1...5)

            if !isLoading {
                HStack {
                    Text("Progress")
                    Slider(value: $activityProgress, in: 0...1)
                    Text("\(Int(activityProgress * 100))%")
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
            }

            Toggle("Auto Delete", isOn: $autoDelete)

            if autoDelete {
                HStack {
                    Text("Delete After")
                    Slider(value: $deleteDelay, in: 1...10)
                    Text("\(Int(deleteDelay))s")
                        .monospacedDigit()
                        .frame(width: 30, alignment: .trailing)
                }
            }

            Button("Add Activity") {
                let activity = activityManager.post(
                    priority: isPriority,
                    title: activityTitle,
                    message: activityMessage,
                    percentage: isLoading ? nil : activityProgress,
                    isLoading: isLoading
                )

                if autoDelete {
                    activityManager.delete(id: activity.id, delay: deleteDelay)
                }
            }

            if !activityManager.activities.isEmpty {
                Button("Clear All Activities") {
                    for activity in activityManager.activities {
                        activityManager.delete(id: activity.id)
                    }
                }
            }

            Section("Progress Timer Test") {
                Button(isProgressTimerRunning ? "Stop Progress Timer" : "Start Progress Timer") {
                    if isProgressTimerRunning {
                        isProgressTimerRunning = false
                        if let activity = progressActivity {
                            activityManager.delete(id: activity.id)
                        }
                        progressActivity = nil
                    } else {
                        isProgressTimerRunning = true
                        progressActivity = activityManager.post(
                            priority: isPriority,
                            title: "Progress Timer",
                            message: "Updating every 50ms",
                            percentage: 0.0
                        )

                        // Start timer to update progress
                        Task { @MainActor in
                            var progress = 0.0
                            while isProgressTimerRunning && progress < 1.0 {
                                // Update in 5% increments
                                progress = min(1.0, progress + 0.05)
                                if let activity = progressActivity {
                                    activityManager.update(
                                        id: activity.id,
                                        percentage: progress
                                    )
                                }
                                // Wait longer between updates
                                try? await Task.sleep(for: .milliseconds(100))
                            }

                            // Cleanup when done
                            if let activity = progressActivity {
                                activityManager.update(
                                    id: activity.id,
                                    title: "Progress Timer Complete",
                                    percentage: 1.0
                                )
                                activityManager.delete(id: activity.id, delay: 2.0)
                            }
                            isProgressTimerRunning = false
                            progressActivity = nil
                        }
                    }
                }
            }
        }
    }
}
