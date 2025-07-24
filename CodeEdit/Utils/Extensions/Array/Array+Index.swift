//
//  Array+Index.swift
//  CodeEdit
//
//  Created by Abe Malla on 7/24/25.
//

extension Array {
    var second: Element? {
        self.count > 1 ? self[1] : nil
    }

    var third: Element? {
        self.count > 2 ? self[2] : nil
    }
}
