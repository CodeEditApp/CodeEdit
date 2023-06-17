//
//  String+camelCaseToProperWord.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 12/06/23.
//

import Foundation

extension String {
    func camelCaseToProperWord() -> String {
        let result = unicodeScalars.dropFirst().reduce(String(prefix(1))) { result, scalar in
            return CharacterSet.uppercaseLetters.contains(scalar)
                ? result + " " + String(scalar)
                : result + String(scalar)
        }

        return result.prefix(1).uppercased() + result.dropFirst()
    }
}
