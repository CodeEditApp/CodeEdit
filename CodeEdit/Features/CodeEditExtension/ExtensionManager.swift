//
//  ExtensionManager.swift
//  
//
//  Created by Matthijs Eikelenboom on 08/10/2022.
//

import Foundation
import CodeEditKit

/// Single class instance that manages the extensions
final class ExtensionManager {
    struct Extension {
        var bundle: Bundle
        var manifest: ExtensionManifest
        var instance: ExtensionInterface
    }

    /// Shared instance of `ExtenstionManager`
    static let shared: ExtensionManager = .init()

    private var loadedBundles: [Bundle] = []
    private var loadedExtentions: [String: Extension] = [:]

    private let codeeditFolder: URL
    private let extensionsFolder: URL
    private let folderMonitor: FolderMonitor

    private init() {
        do {
            self.codeeditFolder = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("CodeEdit", isDirectory: true)
        } catch {
            fatalError("Error while initializing the ExtensionManager, line: 26")
        }
        self.extensionsFolder = codeeditFolder.appendingPathComponent("Extensions", isDirectory: true)

        do {
            try FileManager.default
                .createDirectory(at: self.extensionsFolder,
                                 withIntermediateDirectories: true,
                                 attributes: nil)
        } catch {
            fatalError("Error while initializing the ExtensionManager, line: 36")
        }

        self.folderMonitor = FolderMonitor(url: self.extensionsFolder)
        self.folderMonitor.folderDidChange = self.refreshBundles
        self.folderMonitor.startMonitoring()
    }

    /// This function reads out all the files in the Extension folder
    /// and filters the bundles based on the `.ceext` folder extension
    func refreshBundles() {
        var bundleURLs: [URL] = []
        do {
            bundleURLs = try FileManager.default.contentsOfDirectory(
                at: extensionsFolder,
                includingPropertiesForKeys: nil,
                options: .skipsPackageDescendants
            ).filter({ $0.pathExtension == "ceext" })
        } catch {
            print("Error while refreshing bundles folder")
            return
        }

        for bundleURL in bundleURLs {
            self.preload(bundleURL)
        }
    }

    /// Starts loading all the extensions found in the Extension folder
    /// - Parameter apiBuilder: Function that returns a `ExtensionAPI` subclass to inject into the extension
    func loadExtensions(_ apiBuilder: (String) -> ExtensionAPI) {
        self.refreshBundles()

        for bundle in loadedBundles where bundle.isLoaded {
            self.load(bundle, apiBuilder)
        }
    }

    /// Loads and parses the manifest file of the extension
    /// - Parameter of: The bundle that you want to load the manifest of
    private func loadManifestFile(of bundle: Bundle) -> ExtensionManifest? {
        if let manifestURL = bundle.url(forResource: "manifest", withExtension: "json") {
            do {
                if let rawManifest = try String(contentsOf: manifestURL).data(using: .utf8) {
                    let manifest = try JSONDecoder().decode(ExtensionManifest.self, from: rawManifest)
                    return manifest
                }
            } catch {
                print("An error occured trying to parse the manifest file for: \(bundle.bundlePath)")
                print(error)
            }
            return nil
        } else {
            print("Manifest file not found in: \(bundle.bundlePath)")
        }
        return nil
    }

    // TODO: Reimplement this with XPC
    /// Opens the extension, reads and parses the manifest.json file
    /// - Parameter bundleURL: The URL of the bundle that should be loaded
    ///
    private func preload(_ bundleURL: URL) {
        guard let bundle = Bundle(url: bundleURL) else { return }
        guard bundle.bundleIdentifier != nil else { return }
        if loadedBundles.contains(where: { $0.bundleURL == bundleURL }) { return }

        let loaded = bundle.load()

        if !loaded {
            print("Bundle failed to load")
            return
        }

        if let manifest = self.loadManifestFile(of: bundle) {
            print("Manifest validated for: \(manifest.name)")
            loadedBundles.append(bundle)
        } else {
            print("Invalid manifest for: \(bundle.bundleIdentifier!)")
            bundle.unload()
        }
    }

    // TODO: Reimplement this with XPC
    /// Triggers the build function of the extension and thereby activates the extesion
    ///
    private func load(_ bundle: Bundle, _ apiBuilder: (String) -> ExtensionAPI) {
        for bundle in loadedBundles {
            guard let bundleIdentifier = bundle.bundleIdentifier else { continue }
            guard let manifest = self.loadManifestFile(of: bundle) else { continue }
            guard let builder = bundle.principalClass as? ExtensionBuilder.Type else { continue }

            let api = apiBuilder(bundleIdentifier)
            let extInstance = builder.init().build(withAPI: api)
            print("Activated extension: \(manifest.name)")

            loadedExtentions[bundleIdentifier] = Extension(
                bundle: bundle,
                manifest: manifest,
                instance: extInstance
            )
        }
    }

    private func unload(_ bundle: Bundle) {
        // TODO: Imeplement with XPC
    }
}
