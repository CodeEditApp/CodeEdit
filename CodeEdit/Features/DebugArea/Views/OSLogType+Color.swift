//
//  OSLogType+Color.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/05/2023.
//

import OSLog
import SwiftUI

extension OSLogType {
    var color: Color {
        switch self {
        case .error:
            return .orange
        case .debug, .default:
            return .primary
        case .fault:
            return .red
        case .info:
            return .cyan
        default:
            return .green
        }
    }
}
