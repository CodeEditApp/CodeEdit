//
//  NSPasteboardProvider.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

#if os(macOS)
import AppKit

/// Using an enum to namespace the static functions.
/// If NSPasteboardProvider or other PasteboardProvider implementations might need to
/// hold state in the future, consider using a final class or a struct instead.
enum NSPasteboardProvider: PasteboardProvider {
    @inline(__always)
    static func clear() {
        NSPasteboard.general.clearContents()
    }

    @inline(__always)
    static func string() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }

    @inline(__always)
    static func setString(_ string: String) {
        NSPasteboard.general.setString(string, forType: .string)
    }

    @inline(__always)
    static func setStrings(_ strings: [String]) {
        NSPasteboard.general.writeObjects(strings as [NSString])
    }
}
#endif
