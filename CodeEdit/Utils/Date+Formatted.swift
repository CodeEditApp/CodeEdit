//
//  Date+Formatted.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Lukas Pistrol on 20.04.22.
//

import Foundation

extension Date {

    static var logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        return formatter
    }()

    func logFormatted() -> String {
        Self.logFormatter.string(from: self)
    }
}
