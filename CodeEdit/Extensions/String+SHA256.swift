//
//  String+SHA256.swift
//  CodeEdit
//
//  Created by Debdut Karmakar on 6/9/22.
//

import Foundation
import CryptoKit

extension String {
    var sha256Hash: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
