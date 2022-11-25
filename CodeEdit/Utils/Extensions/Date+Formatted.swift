//
//  Date+Formatted.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Lukas Pistrol on 20.04.22.
//

import Foundation

extension Date {

    /// Returns a formatted & localized string of a relative duration compared to the current date & time
    /// when the date is in `today` or `yesterday`. Otherwise it returns a formatted date in `short`
    /// format. The time is omitted.
    /// - Parameter locale: The locale. Defaults to `Locale.current`
    /// - Returns: A localized formatted string
    func relativeStringToNow(locale: Locale = .current) -> String {
        if Calendar.current.isDateInToday(self) ||
            Calendar.current.isDateInYesterday(self) {
            var style = RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .abbreviated,
                locale: .current,
                calendar: .current,
                capitalizationContext: .standalone
            )

            style.locale = locale

            return self.formatted(style)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = locale

        return formatter.string(from: self)
    }
}
