//
//  SHA256+hash.swift
//  CodeEdit
//
//  Created by Joshua Hoogstraat on 16.04.23.
//

import Foundation
import CryptoKit

extension SHA256 {
    static func hash(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashedData = Self.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
}
