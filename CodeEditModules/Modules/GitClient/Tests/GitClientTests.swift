//
//  File.swift
//  
//
//  Created by Marco Carnevali on 27/03/22.
//

@testable import GitClient
import ShellClient
import XCTest

final class GitClientTests: XCTestCase {
    func testHistory() throws {
        let shellClient: ShellClient = .always(
            "e5fe4bf¦Merge pull request #260 from lukepistrol/terminal-color-fix¦Luke¦Sat, 26 Mar 2022 03:28:12 +0100¦"
        )
        let gitClient: GitClient = .default(
            directoryURL: URL(fileURLWithPath: ""),
            shellClient: shellClient
        )
        print(try gitClient.getCommitHistory(nil))
        XCTAssertEqual(
            try gitClient.getCommitHistory(nil).first!,
            GitClient.Commit(
                hash: "e5fe4bf",
                message: "Merge pull request #260 from lukepistrol/terminal-color-fix",
                author: "Luke",
                date: Date(timeIntervalSince1970: 1648261692)
            )
        )
    }
}
