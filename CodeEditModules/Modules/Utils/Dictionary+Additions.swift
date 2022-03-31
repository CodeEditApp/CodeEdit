//
//  Dictionary+Additions.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

func += <KeyType: ValueType> (
    left: inout [KeyType: ValueType],
    right: [KeyType: ValueType]) {

    for (keyType, valueType) in right {
        left.updateValue(valueType, forKey: keyType)
    }
}
