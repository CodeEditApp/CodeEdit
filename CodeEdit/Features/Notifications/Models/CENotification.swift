//
//  CENotification.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import Foundation
import SwiftUI

struct CENotification: Identifiable, Equatable {
    let id: UUID
    let icon: IconType
    let title: String
    let description: String
    let actionButtonTitle: String
    let action: () -> Void
    let isSticky: Bool
    var isRead: Bool
    let timestamp: Date
    var isBeingDismissed: Bool = false

    enum IconType {
        case symbol(name: String, color: Color?)
        case image(Image)
        case text(String, backgroundColor: Color?, textColor: Color?)
    }

    init(
        id: UUID = UUID(),
        iconSymbol: String,
        iconColor: Color? = nil,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false,
        isRead: Bool = false
    ) {
        self.init(
            id: id,
            icon: .symbol(name: iconSymbol, color: iconColor),
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky,
            isRead: isRead
        )
    }

    init(
        id: UUID = UUID(),
        iconText: String,
        iconTextColor: Color? = nil,
        iconColor: Color? = nil,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false,
        isRead: Bool = false
    ) {
        self.init(
            id: id,
            icon: .text(iconText, backgroundColor: iconColor, textColor: iconTextColor),
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky,
            isRead: isRead
        )
    }

    init(
        id: UUID = UUID(),
        iconImage: Image,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false,
        isRead: Bool = false
    ) {
        self.init(
            id: id,
            icon: .image(iconImage),
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky,
            isRead: isRead
        )
    }

    private init(
        id: UUID,
        icon: IconType,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool,
        isRead: Bool
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
