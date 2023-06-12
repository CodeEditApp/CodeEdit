//
//  String+camelCaseToProperWord.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 12/06/23.
//

import Foundation

extension String {
    func camelCaseToProperWord() -> String {
        var newString: String = ""
        var index: Int = 0

        for character in self {
            let char: String = String(describing: character)

            if character.isLowercase && index != 0 {
                newString += char
            } else if character.isUppercase {
                newString += " \(char)"
            } else if index == 0 {
                newString += char.uppercased()
            }

            index += 1
        }

        return newString
    }
}
