//
//  String+escapedWhiteSpaces.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/07/05.
//

import Foundation

extension String {
    func escapedWhiteSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
}
