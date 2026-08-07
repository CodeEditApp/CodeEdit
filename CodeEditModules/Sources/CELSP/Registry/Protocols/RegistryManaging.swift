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
/// A pure command service: observable presentation state lives on the
/// concrete ``RegistryViewState`` exposed via ``viewState`` (views observe
/// that; a view-state is concrete by nature).
@MainActor
public protocol RegistryManaging: AnyObject {
    var viewState: RegistryViewState { get }
    var installedLanguageServers: [String: SettingsData.InstalledLanguageServer] { get }

    func loadRegistryIfNeeded()
    func setPackageEnabled(packageName: String, enabled: Bool)
    func removeLanguageServer(packageName: String) async throws
    func installOperation(package: RegistryItem) throws -> PackageManagerInstallOperation
    func startInstallation(operation: PackageManagerInstallOperation) throws
    func cancelInstallation()
}
