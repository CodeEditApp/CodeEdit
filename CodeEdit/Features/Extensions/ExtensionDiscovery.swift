//
//  ExtensionDiscovery.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import Foundation
import ExtensionFoundation
import CollectionConcurrencyKit

/// Discovery of available extension endpoints.
final class ExtensionDiscovery: ObservableObject {
    /// Shared instance of this class.
    static var shared = ExtensionDiscovery()

    /// Endpoint used by extensions.
    static var endPointIdentifier = "codeedit.extension"

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
        do {
            let sequence = try AppExtensionIdentity.matching(appExtensionPointIDs: Self.endPointIdentifier)

            for await endpoints in sequence {
                let extensions = await endpoints.concurrentCompactMap {
                    try? await ExtensionInfo(endpoint: $0)
                }
                await MainActor.run {
                    self.extensions = extensions
                }
            }
        } catch {
            print("Error while searching for extensions: \(error.localizedDescription)")
        }
    }

    /// Observes extensions available on the system, and reports if extensions are disabled.
    /// These extensions must be enabled by the user first, before they can be discovered by `discover`.
    /// Warning: This function will continue to run and won't return. Therefore, it should be ran in a separate `Task`.
    private func availabilityOverview() async {
        for await availability in AppExtensionIdentity.availabilityUpdates {
            print(availability)
        }
    }
}
