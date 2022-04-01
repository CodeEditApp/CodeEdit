//
//  Dictionary+Additions.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// swiftlint:disable all
internal func += <KeyType, ValueType> (
    left: inout Dictionary<KeyType, ValueType>,
    right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
