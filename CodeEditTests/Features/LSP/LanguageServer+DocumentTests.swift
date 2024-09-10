//
//  LanguageServer+DocumentTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 9/9/24.
//

import XCTest
import LanguageClient
import LanguageServerProtocol

@testable import CodeEdit

final class LanguageServerDocumentTests: XCTestCase {
    // Test opening documents in CodeEdit triggers creating a language server,
    // further opened documents don't create new servers
    // Test closing documents 
}
