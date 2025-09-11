//
//  GitClientTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 9/11/25.
//

import Testing
@testable import CodeEdit

@Suite
struct GitClientTests {
    @Test
    func statusParseNullAtEnd() throws {
        try withTempDir { dirURL in
            // swiftlint:disable:next line_length
            let string = "1 .M N... 100644 100644 100644 eaef31cfa2a22418c00d7477da0b7151d122681e eaef31cfa2a22418c00d7477da0b7151d122681e CodeEdit/Features/SourceControl/Client/GitClient+Status.swift\01 AM N... 000000 100644 100644 0000000000000000000000000000000000000000 e0f5ce250b32cf6610a284b7a33ac114079f5159 CodeEditTests/Features/SourceControl/GitClientTests.swift\0"
            let client = GitClient(directoryURL: dirURL, shellClient: .live())
            let status = try client.parseStatusString(string)

            #expect(status.changedFiles.count == 2)
            // No null string at the end
            #expect(status.changedFiles[0].fileURL.lastPathComponent == "GitClient+Status.swift")
            #expect(status.changedFiles[1].fileURL.lastPathComponent == "GitClientTests.swift")
        }
    }
}
