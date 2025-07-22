//
//  Registry.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import XCTest
@testable import CodeEdit

@MainActor
final class RegistryTests: XCTestCase {
    var registry: RegistryManager = RegistryManager.shared

    // MARK: - Download Tests

    func testRegistryDownload() async throws {
        await registry.update()

        let registryJsonPath = Settings.shared.baseURL.appending(path: "extensions/registry.json")
        let checksumPath = Settings.shared.baseURL.appending(path: "extensions/checksums.txt")

        XCTAssertTrue(FileManager.default.fileExists(atPath: registryJsonPath.path), "Registry JSON file should exist.")
        XCTAssertTrue(FileManager.default.fileExists(atPath: checksumPath.path), "Checksum file should exist.")
    }

    // MARK: - Decoding Tests

    func testRegistryDecoding() async throws {
        await registry.update()

        let registryJsonPath = Settings.shared.baseURL.appending(path: "extensions/registry.json")
        let jsonData = try Data(contentsOf: registryJsonPath)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entries = try decoder.decode([RegistryItem].self, from: jsonData)

        XCTAssertFalse(entries.isEmpty, "Registry should not be empty after decoding.")

        if let actionlint = entries.first(where: { $0.name == "actionlint" }) {
            XCTAssertEqual(actionlint.description, "Static checker for GitHub Actions workflow files.")
            XCTAssertEqual(actionlint.licenses, ["MIT"])
            XCTAssertEqual(actionlint.languages, ["YAML"])
            XCTAssertEqual(actionlint.categories, ["Linter"])
        } else {
            XCTFail("Could not find actionlint in registry")
        }
    }

    func testHandlesVersionOverrides() async throws {
        await registry.update()

        let registryJsonPath = Settings.shared.baseURL.appending(path: "extensions/registry.json")
        let jsonData = try Data(contentsOf: registryJsonPath)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entries = try decoder.decode([RegistryItem].self, from: jsonData)

        if let adaServer = entries.first(where: { $0.name == "ada-language-server" }) {
            XCTAssertNotNil(adaServer.source.versionOverrides, "Version overrides should be present.")
            XCTAssertFalse(adaServer.source.versionOverrides!.isEmpty, "Version overrides should not be empty.")
        } else {
            XCTFail("Could not find ada-language-server to test version overrides")
        }
    }
}
