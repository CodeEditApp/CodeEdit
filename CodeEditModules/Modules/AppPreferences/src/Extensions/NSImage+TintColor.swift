//
//  NSImage+TintColor.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/26.
//
// swiftlint:disable all

import AppKit

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        return NSImage(size: size, flipped: false) { (rect) -> Bool in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }
}
