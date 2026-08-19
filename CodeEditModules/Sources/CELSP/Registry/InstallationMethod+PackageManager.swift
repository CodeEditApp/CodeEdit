//
//  InstallationMethod+PackageManager.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation
import CodeEditCore

extension InstallationMethod {
    func packageManager(installPath: URL, shellClient: ShellClientProtocol) -> PackageManagerProtocol? {
        switch packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath, shellClient: shellClient)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath, shellClient: shellClient)
        case .pip:
            return PipPackageManager(installationDirectory: installPath, shellClient: shellClient)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath, shellClient: shellClient)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installPath, shellClient: shellClient)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        default:
            return nil
        }
    }
}
