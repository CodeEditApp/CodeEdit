//
//  ExtensionInfo.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import AppKit
import CodeEditKit
import ExtensionFoundation

struct ExtensionInfo: Identifiable, Hashable {

    let endpoint: AppExtensionIdentity

    let availableFeatures: [ExtensionKind]

    let isDebug: Bool

    var id: String {
        endpoint.bundleIdentifier
    }

    var name: String {
        endpoint.localizedName
    }

    var version: String? {
        bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var bundleURL: URL

    var bundle: Bundle?

    var pid: Int32

    func restart() {
        kill(pid, SIGKILL)
    }

    init(endpoint: AppExtensionIdentity) async throws {
        self.endpoint = endpoint

        let process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: endpoint))

        let connection = try process.makeXPCConnection()
        connection.remoteObjectInterface = .init(with: XPCWrappable.self)
        connection.resume()

        defer {
            connection.invalidate()
        }

        self.pid = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionProcessIdentifier {
                continuation.resumingHandler($0, .none)
            }
        }

        self.isDebug = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.isDebug {
                continuation.resumingHandler($0, .none)
            }
        }

        let encodedAvailableFeatures = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionKinds(reply: continuation.resumingHandler)
        }

        self.availableFeatures = try JSONDecoder().decode([ExtensionKind].self, from: encodedAvailableFeatures)

        let bundleURLEncoded = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionURL(reply: continuation.resumingHandler)
        }

        self.bundleURL = try JSONDecoder().decode(URL.self, from: bundleURLEncoded)
        self.bundle = Bundle(url: bundleURL)
    }
}

extension ExtensionInfo {
    /// Bundle identifier of parent app
    var parentBundleIdentifier: String {
        endpoint.bundleIdentifier.split(separator: ".").dropLast().joined(separator: ".")
    }

    var lastPathOfBundleIdentifier: String {
        String(endpoint.bundleIdentifier.split(separator: ".").last!)
    }

    /// Icon of appex folder
    public var icon: NSImage? {
        // TODO: Use icon of extension instead of parent app
        // A way to get the path of an .appex file should be used.
        // Unfortunately, NSWorkspace.shared.urlForApplication only seems to work for .app
        let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: parentBundleIdentifier)
        guard let path else { return nil }

        return NSWorkspace.shared.icon(forFile: path.path)
    }
}
