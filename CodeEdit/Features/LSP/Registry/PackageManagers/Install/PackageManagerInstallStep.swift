//
//  PackageManagerInstallStep.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/18/25.
//

/// Represents a single executable step in a package install.
struct PackageManagerInstallStep: Identifiable {
    var id: String { name }
    let name: String
    let confirmation: InstallStepConfirmation
    let handler: (_ model: PackageManagerProgressModel) async throws -> Void
}
