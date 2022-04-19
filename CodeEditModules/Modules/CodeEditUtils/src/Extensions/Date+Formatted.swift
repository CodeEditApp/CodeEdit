//
//  Date+Formatted.swift
//  
//
//  Created by Lukas Pistrol on 20.04.22.
//

import Foundation

public extension Date {
    func relativeStringToNow() -> String {
        if Calendar.current.isDateInToday(self) ||
            Calendar.current.isDateInYesterday(self) {
            let style = RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .abbreviated,
                locale: .current,
                calendar: .current,
                capitalizationContext: .standalone
            )

            return self.formatted(style)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        return formatter.string(from: self)
    }
}
