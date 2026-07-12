//
//  TrimWhitespaceFormatter.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/28/24.
//

import SwiftUI

class TrimWhitespaceFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        obj?.pointee = string.trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        return true
    }

    override func isPartialStringValid(
        _ partialString: String,
        newEditingString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        let trimmed = partialString.trimmingCharacters(in: .whitespacesAndNewlines)
        newEditingString?.pointee = trimmed as NSString
        return true
    }
}
