//
//  String+Ranges.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import Foundation

extension StringProtocol where Index == String.Index {
    func ranges<T: StringProtocol>(
        of substring: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let result = range(
            of: substring,
            options: options,
            range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
            locale: locale
        ) {
            ranges.append(result)
        }
        return ranges
    }
}
