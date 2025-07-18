//
//  LocalProcess+sendText.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/15/25.
//

import SwiftTerm

extension LocalProcess {
    func send(text: String) {
        let array = Array(text.utf8)
        self.send(data: array[0..<array.count])
    }
}
