//
//  Registry.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Testing
import Foundation
@testable import CodeEdit

@MainActor
@Suite()
struct RegistryTests {
    var registry: RegistryManager = RegistryManager()

    // MARK: - Download Tests

    @Test
    func registryDownload() async throws {
        await registry.downloadRegistryItems()

        #expect(registry.downloadError == nil)

        let registryJsonPath = registry.installPath.appending(path: "registry.json")
        let checksumPath = registry.installPath.appending(path: "checksums.txt")

        #expect(FileManager.default.fileExists(atPath: registryJsonPath.path), "Registry JSON file should exist.")
        #expect(FileManager.default.fileExists(atPath: checksumPath.path), "Checksum file should exist.")
    }

    // MARK: - Decoding Tests

    @Test
    func registryDecoding() async throws {
        await registry.downloadRegistryItems()

        let registryJsonPath = registry.installPath.appending(path: "registry.json")
        let jsonData = try Data(contentsOf: registryJsonPath)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entries = try decoder.decode([RegistryItem].self, from: jsonData)

        #expect(entries.isEmpty == false, "Registry should not be empty after decoding.")

        if let actionlint = entries.first(where: { $0.name == "actionlint" }) {
            #expect(actionlint.description == "Static checker for GitHub Actions workflow files.")
            #expect(actionlint.licenses == ["MIT"])
            #expect(actionlint.languages == ["YAML"])
            #expect(actionlint.categories == ["Linter"])
        } else {
            Issue.record("Could not find actionlint in registry")
        }
    }

    @Test
    func handlesVersionOverrides() async throws {
        await registry.downloadRegistryItems()

        let registryJsonPath = registry.installPath.appending(path: "registry.json")
        let jsonData = try Data(contentsOf: registryJsonPath)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let entries = try decoder.decode([RegistryItem].self, from: jsonData)

        if let adaServer = entries.first(where: { $0.name == "ada-language-server" }) {
            #expect(adaServer.source.versionOverrides != nil, "Version overrides should be present.")
            #expect(adaServer.source.versionOverrides!.isEmpty == false, "Version overrides should not be empty.")
        } else {
            Issue.record("Could not find ada-language-server to test version overrides")
        }
    }
}
