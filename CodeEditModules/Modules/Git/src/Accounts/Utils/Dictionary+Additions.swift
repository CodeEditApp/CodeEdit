//
//  Dictionary+Additions.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

internal func += <KeyType, ValueType> (
    left: inout [KeyType: ValueType],
    right: [KeyType: ValueType]) {

    for (key, val) in right {
        left.updateValue(val, forKey: key)
    }
}
