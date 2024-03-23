//
//  UIPasteboardProvider.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

#if os(iOS)
import UIKit

/// Using an enum to namespace the static functions.
/// If UIPasteboardProvider or other PasteboardProvider implementations might need to
/// hold state in the future, consider using a final class or a struct instead.
enum UIPasteboardProvider: PasteboardProvider {
    @inline(__always)
    static func clear() {
        UIPasteboard.general.string = nil
    }

    @inline(__always)
    static func string() -> String? {
        return UIPasteboard.general.string
    }

    @inline(__always)
    static func setString(_ string: String) {
        UIPasteboard.general.string = string
    }

    @inline(__always)
    static func setStrings(_ strings: [String]) {
        UIPasteboard.general.strings = strings
    }
}
#endif
