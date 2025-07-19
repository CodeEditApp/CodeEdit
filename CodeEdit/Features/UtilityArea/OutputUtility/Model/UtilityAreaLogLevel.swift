//
//  UtilityAreaLogLevel.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import SwiftUI

enum UtilityAreaLogLevel {
    case error
    case warning
    case info
    case debug

    var iconName: String {
        switch self {
        case .error:
            "exclamationmark.3"
        case .warning:
            "exclamationmark.2"
        case .info:
            "info"
        case .debug:
            "stethoscope"
        }
    }

    var color: Color {
        switch self {
        case .error:
            return Color(red: 202.0/255.0, green: 27.0/255.0, blue: 0)
        case .warning:
            return Color(red: 255.0/255.0, green: 186.0/255.0, blue: 0)
        case .info:
            return .cyan
        case .debug:
            return .coolGray
        }
    }

    var backgroundColor: Color {
        switch self {
        case .error:
            color.opacity(0.1)
        case .warning:
            color.opacity(0.2)
        case .info, .debug:
                .clear
        }
    }
}
