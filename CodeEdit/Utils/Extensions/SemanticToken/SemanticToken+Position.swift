//
//  SemanticToken+Position.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import LanguageServerProtocol

extension SemanticToken {
    var startPosition: Position {
        Position(line: Int(line), character: Int(char))
    }

    var endPosition: Position {
        Position(line: Int(line), character: Int(char + length))
    }
}
