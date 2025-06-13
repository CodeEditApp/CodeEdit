//
//  Int+HexString.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/13/25.
//

extension UInt {
    init?(hexString: String) {
        // Trim 0x if it's there
        let string = String(hexString.trimmingPrefix("0x"))
        guard let value = UInt(string, radix: 16) else {
            return nil
        }
        self = value
    }
}

extension Int {
    init?(hexString: String) {
        // Trim 0x if it's there
        let string = String(hexString.trimmingPrefix("0x"))
        guard let value = Int(string, radix: 16) else {
            return nil
        }
        self = value
    }
}
