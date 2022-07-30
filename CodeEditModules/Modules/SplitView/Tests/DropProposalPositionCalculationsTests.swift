//
//  DropProposalPositionCalculationsTests.swift
//  CodeEditModules/SplitView
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
@testable import SplitEditors
import XCTest

final class DropProposalPositionCalculationsTests: XCTestCase {
    func testPointInLeadingReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 1, y: 1)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertEqual(result, .leading)
    }

    func testPointInTrailingReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 9, y: 9)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertEqual(result, .trailing)
    }

    func testPointInTopReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 5, y: 2)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertEqual(result, .top)
    }

    func testPointInBottomReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 5, y: 8)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertEqual(result, .bottom)
    }

    func testPointInCenterReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 5, y: 5)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertEqual(result, .center)
    }

    func testPointOutsideReact() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let point = CGPoint(x: 100, y: 100)
        let margin = CGFloat(3)

        let result = calculateDropProposalPosition(
            in: rect,
            for: point,
            margin: margin
        )

        XCTAssertNil(result)
    }
}
