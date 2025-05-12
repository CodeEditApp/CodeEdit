//
//  PackageManagerError.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/12/25.
//

enum PackageManagerError: Error {
    case packageManagerNotInstalled
    case initializationFailed(String)
    case installationFailed(String)
    case invalidConfiguration
}
