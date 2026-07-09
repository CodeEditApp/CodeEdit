//
//  RegistryManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import Foundation
import CodeEditSettings
import CodeEditCore

/// Protocol for managing the language server registry.
///
/// Note: `@Published` properties are not included because consumers
/// need the concrete type for SwiftUI observation. Use `RegistryManager` directly in views.
@MainActor
protocol RegistryManaging: AnyObject, ObservableObject {
    var installedLanguageServers: [String: SettingsData.InstalledLanguageServer] { get }
    var isInstalling: Bool { get }

    func setPackageEnabled(packageName: String, enabled: Bool)
    func removeLanguageServer(packageName: String) async throws
    func installOperation(package: RegistryItem) throws -> PackageManagerInstallOperation
    func startInstallation(operation: PackageManagerInstallOperation) throws
    func cancelInstallation()
}
