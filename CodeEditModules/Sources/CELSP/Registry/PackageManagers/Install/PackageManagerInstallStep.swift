//
//  PackageManagerInstallStep.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/18/25.
//

/// Represents a single executable step in a package install.
public struct PackageManagerInstallStep: Identifiable {
    public var id: String { name }
    public let name: String
    public let confirmation: InstallStepConfirmation
    let handler: (_ model: PackageManagerProgressModel) async throws -> Void
}
