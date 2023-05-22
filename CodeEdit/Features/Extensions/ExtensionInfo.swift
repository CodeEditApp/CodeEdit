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

    var id: String {
        endpoint.bundleIdentifier
    }

    var name: String {
        endpoint.localizedName
    }

    var version: String? {
        bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    init(endpoint: AppExtensionIdentity) async throws {
        self.endpoint = endpoint
        self.availableFeatures = try await Self.getAvailableFeatures(endpoint: endpoint)
        self.bundleURL = try await Self.getBundleURL(endpoint: endpoint)
        self.pid = try await Self.getProcessIdentifier(endpoint: endpoint)
        self.bundle = Bundle(url: bundleURL)
    }

    var bundleURL: URL

    var bundle: Bundle?

    var pid: Int32

    private static func getProcessIdentifier(endpoint: AppExtensionIdentity) async throws -> Int32 {
        let process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: endpoint))

        let connection = try process.makeXPCConnection()
        connection.remoteObjectInterface = .init(with: XPCWrappable.self)
        connection.resume()

        defer {
            connection.invalidate()
        }

        let identifier = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionProcessIdentifier {
                continuation.resumingHandler($0, .none)
            }
        }

        return identifier
    }

    private static func getBundleURL(endpoint: AppExtensionIdentity) async throws -> URL {
        let process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: endpoint))

        let connection = try process.makeXPCConnection()
        connection.remoteObjectInterface = .init(with: XPCWrappable.self)
        connection.resume()

        defer {
            connection.invalidate()
        }

        let encoded = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionURL(reply: continuation.resumingHandler)
        }

        return try JSONDecoder().decode(URL.self, from: encoded)
    }

    static func getAvailableFeatures(endpoint: AppExtensionIdentity) async throws -> [ExtensionKind] {
        let process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: endpoint))

        let connection = try process.makeXPCConnection()
        connection.remoteObjectInterface = .init(with: XPCWrappable.self)
        connection.resume()

        defer {
            connection.invalidate()
        }

        let encoded = try await connection.withContinuation { (service: XPCWrappable, continuation) in
            service.getExtensionKinds(reply: continuation.resumingHandler)
        }

        return try JSONDecoder().decode([ExtensionKind].self, from: encoded)
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
