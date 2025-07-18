//
//  ShellIntegrationTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 6/11/24.
//

import Foundation
import SwiftUI
import XCTest
@testable import CodeEdit

final class ShellIntegrationTests: XCTestCase {
    func testBash() throws {
        var environment: [String] = []
        let args = try ShellIntegration.setUpIntegration(
            for: .bash,
            environment: &environment,
            useLogin: false,
            interactive: true
        )
        XCTAssertTrue(
            environment.contains("\(ShellIntegration.Variables.ceInjection)=1"), "Does not contain injection flag"
        )
        XCTAssertTrue(
            !environment.contains("\(ShellIntegration.Variables.shellLogin)=1"), "Should not contain login flag"
        )
        XCTAssertTrue(args.contains("--init-file"), "No init file flag")
        XCTAssertTrue(
            args.contains(where: { $0.hasSuffix("/codeedit_shell_integration.bash") }), "No setup file provided in args"
        )
        XCTAssertTrue(args.contains("-i"), "No interactive flag found")
    }

    func testBashLogin() throws {
        var environment: [String] = []
        let args = try ShellIntegration.setUpIntegration(
            for: .bash,
            environment: &environment,
            useLogin: true,
            interactive: true
        )
        XCTAssertTrue(
            environment.contains("\(ShellIntegration.Variables.ceInjection)=1"), "Does not contain injection flag"
        )
        XCTAssertTrue(environment.contains("\(ShellIntegration.Variables.shellLogin)=1"), "Does not contain login flag")
        XCTAssertTrue(args.contains("--init-file"), "No init file flag")
        XCTAssertTrue(
            args.contains(where: { $0.hasSuffix("/codeedit_shell_integration.bash") }), "No setup file provided in args"
        )
        XCTAssertTrue(args.contains("-il"), "No interactive login flag found")
    }

    func testZsh() throws {
        var environment: [String] = []
        let args = try ShellIntegration.setUpIntegration(
            for: .zsh,
            environment: &environment,
            useLogin: false,
            interactive: true
        )
        XCTAssertTrue(args.contains("-i"), "Interactive flag")
        XCTAssertTrue(!args.contains("-il"), "No Interactive/Login flag")

        XCTAssertTrue(
            environment.contains("\(ShellIntegration.Variables.ceInjection)=1"), "Does not contain injection flag"
        )
        XCTAssertTrue(
            !environment.contains("\(ShellIntegration.Variables.shellLogin)=1"), "Should not contain login flag"
        )
        XCTAssertTrue(environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.zDotDir) }))
        XCTAssertTrue(environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.userZDotDir) }))
        // Should not use this one
        XCTAssertTrue(!environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.ceZDotDir) }))

        guard var tempDir = environment.first(where: { $0.hasPrefix(ShellIntegration.Variables.zDotDir) }) else {
            XCTFail("No temp dir")
            return
        }
        // trim "ZDOTDIR=" from var
        tempDir = String(tempDir.dropFirst(ShellIntegration.Variables.zDotDir.count + 1))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zshrc")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zprofile")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zlogin")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zshenv")))
    }

    func testZshLogin() throws {
        var environment: [String] = []
        let args = try ShellIntegration.setUpIntegration(
            for: .zsh,
            environment: &environment,
            useLogin: true,
            interactive: true
        )
        XCTAssertTrue(!args.contains("-i"), "No Interactive flag")
        XCTAssertTrue(args.contains("-il"), "Interactive/Login flag")

        XCTAssertTrue(
            environment.contains("\(ShellIntegration.Variables.ceInjection)=1"), "Does not contain injection flag"
        )
        XCTAssertTrue(
            environment.contains("\(ShellIntegration.Variables.shellLogin)=1"), "Does not contain login flag"
        )
        XCTAssertTrue(environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.zDotDir) }))
        XCTAssertTrue(environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.userZDotDir) }))
        // Should not use this one
        XCTAssertTrue(!environment.contains(where: { $0.hasPrefix(ShellIntegration.Variables.ceZDotDir) }))

        guard var tempDir = environment.first(where: { $0.hasPrefix(ShellIntegration.Variables.zDotDir) }) else {
            XCTFail("No temp dir")
            return
        }
        // trim "ZDOTDIR=" from var
        tempDir = String(tempDir.dropFirst(ShellIntegration.Variables.zDotDir.count + 1))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zshrc")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zprofile")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zlogin")))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appending("/.zshenv")))
    }
}
