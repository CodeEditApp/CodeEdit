//
//  Time.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum Time {

    /**
     A date formatter for RFC 3339 style timestamps.
     Uses POSIX locale and GMT timezone so that date values are parsed as absolutes.
     - (https://tools.ietf.org/html/rfc3339)
     - (https://developer.apple.com/library/mac/qa/qa1480/_index.html)
     */
    public static var rfc3339DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
