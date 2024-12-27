//
//  SemanticTokenStorageTests.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import XCTest
import CodeEditSourceEditor
import LanguageServerProtocol
@testable import CodeEdit

final class SemanticTokenStorageTests: XCTestCase {
    func testInvalidation() {
        let storage = ConcreteSemanticTokenStorage()
        storage.state = ConcreteSemanticTokenStorage.CurrentState(
            requestId: nil,
            tokenData: [0, 0, 2, 0, 0],
            tokens: [SemanticToken(line: 0, char: 0, length: 2, type: 0, modifiers: 0)]
        )
    }
}
