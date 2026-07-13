//
//  RegistryViewState.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Foundation
import CodeEditCore

/// Observable presentation state for the language-server registry.
/// Owned and fed by ``RegistryManager``; observed by the Settings extension
/// pages. Split out so the manager itself is a pure command service.
@MainActor
public final class RegistryViewState: ObservableObject {
    @Published public internal(set) var isDownloadingRegistry: Bool = false
    /// Holds any error found while downloading the registry file. Needs a UI to dismiss, is logged.
    @Published public internal(set) var downloadError: Error?
    /// Any currently running installation operation.
    @Published public internal(set) var runningInstall: PackageManagerInstallOperation?
    /// Indicates if the manager is currently installing a package.
    @Published public internal(set) var isInstalling: Bool = false
    @Published public internal(set) var registryItems: [RegistryItem] = []
}
