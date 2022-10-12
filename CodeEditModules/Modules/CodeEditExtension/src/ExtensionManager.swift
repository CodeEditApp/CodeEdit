//
//  File.swift
//  
//
//  Created by Matthijs Eikelenboom on 08/10/2022.
//

import Foundation

/// Single class instance that manages the extensions
public final class ExtensionManager {

    /// Shared instance of `ExtenstionManager`
    public static let shared: ExtensionManager = .init()

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

        self.folderMonitor = FolderMonitor(url: self.extensionsFolder) {
            print("Test")
        }
        self.folderMonitor.startMonitoring()
    }

    /// Opens the extension, reads and parses the manifest.json file
    public func preload() {
        // Read out current files in the Extensions directory
        // Parse manifest files and register onActivate functions
    }

    /// Activate a specific extension
    public func load(extensionId: String) {

    }
}
