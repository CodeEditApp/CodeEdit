//
//  ExtensionManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import Foundation
import SwiftUI
import ExtensionFoundation
import CodeEditKit
import ConcurrencyPlus

typealias CEExtension = AppExtensionIdentity

extension CEExtension: Identifiable {
    public var id: String {
        self.bundleIdentifier + self.localizedName
    }

    public var parentBundleIdentifier: String {
        bundleIdentifier.split(separator: ".").dropLast().joined(separator: ".")
    }

    public var icon: NSImage? {
        // TODO: Use icon of extension instead of parent app
        // A way to get the path of an .appex file should be used.
        // Unfortunately, NSWorkspace.shared.urlForApplication only seems to work for .app
        let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: parentBundleIdentifier)
        guard let path else { return nil }
        return NSWorkspace.shared.icon(forFile: path.path)
    }
}

enum ExtensionID: String {
    case general = "codeedit.extension"
    case ui = "codeedit.uiextension"
}

final class ExtensionManager: ObservableObject {

    @Published var extensions: [CEExtension] = [] {
        didSet {
            Task {
                await printExtensionKinds(extensions: extensions)
            }
        }
    }

    init() {
        Task {
            await discover()
            for await availability in AppExtensionIdentity.availabilityUpdates {
                print(availability)
            }

        }
    }

    func discover() async {
        do {
            let sequence = try AppExtensionIdentity.matching(appExtensionPointIDs: ExtensionID.general.rawValue, ExtensionID.ui.rawValue)
            print("FOUND EXTENSIONS")
            for await identities in sequence {
                await MainActor.run {
                    self.extensions = identities
                }
            }
        } catch {
            print("Error while searching for extensions: \(error.localizedDescription)")
        }
    }

    func printExtensionKinds(extensions: [CEExtension]) async {
        do {
            for ext in extensions {
                let process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: ext))

                let connection = try process.makeXPCConnection()
                connection.remoteObjectInterface = .init(with: XPCWrappable.self)
                connection.resume()

                let encoded = try await connection.withContinuation { (service: XPCWrappable, continuation) in
                    service.getExtensionKinds(reply: continuation.resumingHandler)
                }

                let decoded = try JSONDecoder().decode([ExtensionKind].self, from: encoded)

                print("DECODED: \(decoded)")
            }
        } catch {
            print("DECODED \(error)")
        }
    }
}
