//
//  XCUIElement+Snapshot.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/14/24.
//

import XCTest
import AppKit

extension XCUIElement {
    func normalizedScreenshot() -> NSImageView {
        let image = self.screenshot().image
        let imageView = NSImageView(image: image)
        imageView.frame.size = image.size
        return imageView
    }
}

