//
//  Bundle+Info.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Lukas Pistrol on 01.05.22.
//

import Foundation

extension Bundle {

    /// Returns the main bundle's version string if available (e.g. 1.0.0)
    static var versionString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the main bundle's build string if available (e.g. 123)
    static var buildString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
