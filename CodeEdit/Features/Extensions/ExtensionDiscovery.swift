//
//  ExtensionDiscovery.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import Foundation
import ExtensionFoundation
import CollectionConcurrencyKit
import GRDB

/// Discovery of available extension endpoints.
final class ExtensionDiscovery: ObservableObject {
    /// Shared instance of this class.
    static var shared = ExtensionDiscovery()

    /// Endpoint used by extensions.
    static var endPointIdentifier = "codeedit.extension"

    private static var dbURL = URL.libraryDirectory
        .appending(path: "Preferences/com.apple.LaunchServices/com.apple.LaunchServices.SettingsStore.sql")

    /// Publishes a list of extension endpoints approved by the user.
    /// These endpoints can be used to create new extension processes with XPC.
    @Published var extensions: [ExtensionInfo] = []

    // Init is private as only 1 instance of this class may (needs to) exist.
    private init() {
        // Two separate tasks need to be used, as the awaits never finish.
        Task {
            await discover()
        }

        Task {
            await availabilityOverview()
        }
    }

    /// Discover all the extensions approved by the user. Updates `extensions` when an extension gets enabled/disabled.
    /// Warning: This function will continue to run and won't return. Therefore, it should be ran in a separate `Task`.
    private func discover() async {
        print("Change in active extensions, reconnecting...")
        do {
            let sequence = try AppExtensionIdentity.matching(appExtensionPointIDs: Self.endPointIdentifier)

            for await endpoints in sequence {
                await updateExtensions(endpoints: endpoints, shouldRestartExisting: true)
            }
        } catch {
            print("Error while searching for extensions: \(error.localizedDescription)")
        }
    }

    private func updateExtensions(endpoints: [AppExtensionIdentity], shouldRestartExisting: Bool = false) async {
        let extensions = await endpoints.concurrentCompactMap {
            try? await ExtensionInfo(endpoint: $0)
        }

        await MainActor.run {
            self.extensions = extensions
        }

        if shouldRestartExisting {
            self.extensions.filter(\.isDebug)
                .forEach {
                    print("Restarting \($0.name)...")
                    $0.restart()
                }
        }
    }

    /// Observes extensions available on the system, and reports if extensions are disabled.
    /// These extensions must be enabled by the user first, before they can be discovered by `discover`.
    /// Warning: This function will continue to run and won't return. Therefore, it should be ran in a separate `Task`.
    private func availabilityOverview() async {
        for await availability in AppExtensionIdentity.availabilityUpdates {
            print(availability)
            do {
                if availability.disabledCount > 0 {
                    print("Found \(availability.disabledCount) disabled extensions, trying to activate...")
                    try await activateDisabledExtensions()
                }

                if availability.unapprovedCount > 0 {
                    print("Found \(availability.disabledCount) unapproved extensions, trying to activate...")

                    let identifiers = [("com.tweety.TestCodeEdit.AutoActivatedExtension", "2MMGJGVTB4")]
                    try await activateUnapprovedExtensions(with: identifiers)
                }

                let sequence = try AppExtensionIdentity.matching(appExtensionPointIDs: Self.endPointIdentifier)

                let extensions = await sequence.first { _ in true }

                guard let extensions else { return }
                await updateExtensions(endpoints: extensions)
            } catch {
                print("Could not auto-activate extensions.")
            }
        }
    }

    struct SettingsStoreRecord: Codable, TableRecord, FetchableRecord, PersistableRecord {
        var identifier: String
        var timestamp: String
        var userElection: Int

        static var databaseTableName: String = "Election"
    }

    private func activateDisabledExtensions() async throws {
        let dbQueue = try DatabaseQueue(path: Self.dbURL.path())

        return try await dbQueue.write {
            try SettingsStoreRecord
                .filter(Column("identifier").like("%\(Self.endPointIdentifier)%"))
                .filter(Column("userElection") == 2)
                .updateAll($0, Column("userElection") -= 1)
        }
    }

    private func activateUnapprovedExtensions(with identifiers: [(bundleID: String, devID: String)]) async throws {
        let dbQueue = try DatabaseQueue(path: Self.dbURL.path())

        return try await dbQueue.write { table in
            try identifiers.map { identifier in
                SettingsStoreRecord(
                    // swiftlint:disable:next line_length
                    identifier: "\(Bundle.main.bundleIdentifier!)::\(Self.endPointIdentifier):\(identifier.bundleID):\(identifier.devID)",
                    timestamp: String(Date.now.description.dropLast(6)),
                    userElection: 1
                )
            }.forEach {
                try $0.save(table)
            }
        }
    }
}
