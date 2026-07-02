//
//  TaskNotificationModel.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import Foundation

/// Represents a notifications or tasks, that are displayed in the activity viewer
public struct TaskNotificationModel: Equatable {
    public var id: String
    public var title: String
    public var message: String?
    public var percentage: Double?
    public var isLoading: Bool = false

    public init(id: String, title: String, message: String? = nil, percentage: Double? = nil, isLoading: Bool = false) {
        self.id = id
        self.title = title
        self.message = message
        self.percentage = percentage
        self.isLoading = isLoading
    }
}
