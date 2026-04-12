//
//  InstallationMethod+PackageManager.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation
import CodeEditDomain

extension InstallationMethod {
    func packageManager(installPath: URL) -> PackageManagerProtocol? {
        switch packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath)
        case .pip:
            return PipPackageManager(installationDirectory: installPath)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installPath)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        default:
            return nil
        }
    }
}
