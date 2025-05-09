//
//  CEWorkspaceSettingsTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 4/21/25.
//

import Foundation
import Testing
@testable import CodeEdit

struct CEWorkspaceSettingsTests {
    let settings: CEWorkspaceSettings = CEWorkspaceSettings(workspaceURL: URL(filePath: "/"))

    @Test
    func settingsURLNoSpace() async throws {
        #expect(settings.folderURL.lastPathComponent == ".codeedit")
        #expect(settings.settingsURL.lastPathComponent == "settings.json")
    }
}
