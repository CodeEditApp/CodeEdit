//
//  SemanticTokenMapRangeProvider.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/19/24.
//

import Foundation

@MainActor
protocol SemanticTokenMapRangeProvider {
    func nsRangeFrom(line: UInt32, char: UInt32, length: UInt32) -> NSRange?
}
