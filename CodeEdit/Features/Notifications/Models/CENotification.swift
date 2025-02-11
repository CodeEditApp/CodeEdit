import SwiftUI

struct CENotification: Identifiable, Equatable {
    let id: UUID
    let icon: String // SF Symbol name
    let title: String
    let description: String
    let actionButtonTitle: String
    let action: () -> Void
    let isSticky: Bool
    var isRead: Bool
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        icon: String,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false,
        isRead: Bool = false
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.description = description
        self.actionButtonTitle = actionButtonTitle
        self.action = action
        self.isSticky = isSticky
        self.isRead = isRead
        self.timestamp = Date()
    }
    
    static func == (lhs: CENotification, rhs: CENotification) -> Bool {
        lhs.id == rhs.id
    }
} 
