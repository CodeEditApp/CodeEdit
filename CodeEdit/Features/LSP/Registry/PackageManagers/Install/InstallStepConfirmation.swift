//
//  InstallStepConfirmation.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

enum InstallStepConfirmation {
    case none
    case required(message: String)
}

struct PackageManagerInstallStep: Identifiable {
    var id: String { name }
    let name: String
    let confirmation: InstallStepConfirmation
    let handler: (_ model: PackageManagerProgressModel) async throws -> Void
}
