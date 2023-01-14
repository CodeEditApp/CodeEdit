//
//  AcknowledgementsTests.swift
//  CodeEditTests
//
//  Created by Lukas Pistrol on 14.01.23.
//

import XCTest
@testable import CodeEdit

final class AcknowledgementsTests: XCTestCase {

    var model: AcknowledgementsViewModel!

    override func setUpWithError() throws {
        model = .init()
    }

    override func tearDownWithError() throws {
        model = nil
    }

    func testAcknowledgementsNotEmpty() throws {
        XCTAssertFalse(model.acknowledgements.isEmpty)
    }
}
