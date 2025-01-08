//
//  UtilityAreaViewModelTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 1/7/25.
//

import XCTest
@testable import CodeEdit

final class UtilityAreaViewModelTests: XCTestCase {
    var model: UtilityAreaViewModel!
    let rootURL: URL = URL(filePath: "~/")

    override func setUp() {
        model = UtilityAreaViewModel()
        model.terminals = [
            UtilityAreaTerminal(id: UUID(), url: rootURL, title: "Terminal 1", shell: .bash),
            UtilityAreaTerminal(id: UUID(), url: rootURL, title: "Terminal 2", shell: .zsh),
            UtilityAreaTerminal(id: UUID(), url: rootURL, title: "Terminal 3", shell: nil),
            UtilityAreaTerminal(id: UUID(), url: rootURL, title: "Terminal 4", shell: .bash),
            UtilityAreaTerminal(id: UUID(), url: rootURL, title: "Terminal 5", shell: .zsh)
        ]
    }

    func testRemoveLastTerminal() {
        let originalTerminals = model.terminals.map { $0.id }
        model.removeTerminals(Set([originalTerminals[4]]))
        XCTAssertEqual(model.terminals.count, 4)
        XCTAssertEqual(Array(originalTerminals[0..<4]), model.terminals.map({ $0.id }))
    }

    func testRemoveMiddleTerminal() {
        let originalTerminals = model.terminals.map { $0.id }
        model.removeTerminals(Set([originalTerminals[2]]))
        XCTAssertEqual(model.terminals.count, 4)
        XCTAssertEqual(
            Array(originalTerminals[0..<2]) + Array(originalTerminals[3..<5]),
            model.terminals.map({ $0.id })
        )
    }

    func testRemoveFirstTerminal() {
        let originalTerminals = model.terminals.map { $0.id }
        model.removeTerminals(Set([originalTerminals[0]]))
        XCTAssertEqual(model.terminals.count, 4)
        XCTAssertEqual(Array(originalTerminals[1..<5]), model.terminals.map({ $0.id }))
    }

    func testRemoveAllTerminals() {
        let originalTerminals = model.terminals.map { $0.id }
        model.removeTerminals(Set(originalTerminals))
        XCTAssertEqual(model.terminals, [])
    }

    // Skipping this test. The semantics of updating terminal titles needs work.
    func _testUpdateTerminalTitle() {
        model.updateTerminal(model.terminals[0].id, title: "Custom Title")
        XCTAssertFalse(model.terminals[0].customTitle) // This feels wrong, but it's how this view model is set up.
        XCTAssertEqual(model.terminals[0].title, "Custom Title")

        model.updateTerminal(model.terminals[0].id, title: nil)
        XCTAssertFalse(model.terminals[0].customTitle)
        // Should stay the same title, just disables the custom title.
        XCTAssertEqual(model.terminals[0].title, "Custom Title")
    }

    func testAddTerminal() {
        model.addTerminal(shell: nil, rootURL: rootURL)
        XCTAssertEqual(model.terminals.count, 6)
        XCTAssertEqual(model.terminals[5].shell, nil)
        XCTAssertEqual(model.terminals[5].title, "terminal")
        XCTAssertFalse(model.terminals[5].customTitle)
        XCTAssertEqual(model.terminals[5].url, rootURL)
    }

    func testAddTerminalCustomShell() {
        model.addTerminal(shell: .bash, rootURL: rootURL)
        XCTAssertEqual(model.terminals.count, 6)
        XCTAssertEqual(model.terminals[5].shell, .bash)
        XCTAssertEqual(model.terminals[5].title, Shell.bash.rawValue)
        XCTAssertFalse(model.terminals[5].customTitle)
        XCTAssertEqual(model.terminals[5].url, rootURL)

        model.addTerminal(shell: .zsh, rootURL: rootURL)
        XCTAssertEqual(model.terminals.count, 7)
        XCTAssertEqual(model.terminals[6].shell, .zsh)
        XCTAssertEqual(model.terminals[6].title, Shell.zsh.rawValue)
        XCTAssertFalse(model.terminals[6].customTitle)
        XCTAssertEqual(model.terminals[6].url, rootURL)
    }

    func testReplaceTerminal() {
        let terminalToReplace = model.terminals[2]
        model.replaceTerminal(terminalToReplace.id)
        XCTAssertNotEqual(model.terminals[2].id, terminalToReplace.id)
        XCTAssertEqual(model.terminals[2].shell, terminalToReplace.shell)
        XCTAssertEqual(model.terminals[2].url, terminalToReplace.url)
    }

    func testInitializeTerminals() {
        let terminals = model.terminals
        model.initializeTerminals(workspaceURL: rootURL)
        XCTAssertEqual(terminals, model.terminals) // Should not modify if terminals exist

        // Remove all terminals so it can do something
        model.removeTerminals(Set(model.terminals.map { $0.id }))
        XCTAssertEqual(model.terminals.count, 0, "Model did not delete all terminals")

        model.initializeTerminals(workspaceURL: rootURL)
        XCTAssertEqual(model.terminals.count, 1)
    }
}
