//
//  Bundle+Info.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/21/24.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Foundation
#endif

extension Bundle {

    /// Returns the version and build of the platform
    static var systemVersionBuild: String {
        #if os(iOS)
        // Example output: "17.0"
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let url = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
        guard let dict = NSDictionary(contentsOf: url),
              let version = dict["ProductUserVisibleVersion"],
              let build = dict["ProductBuildVersion"] else {
            return ProcessInfo.processInfo.operatingSystemVersionString
        }
        // Example output: "14.4 (23E214)""
        return "\(version) (\(build))"
        #else
        // Example output: "Version 14.4 (Build 23E214)""
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }

    /// Returns the version of the system, including the patch version (e.g. 14.4.0)
    static var systemVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    /// Returns the name of the operating system (e.g. iOS, macOS, Web)
    static var systemName: String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "macOS"
        #elseif os(WASI)
        return "Web"
        #endif
    }

    /// Returns the platform name (e.g. iPhone, iPad, Mac)
    static var deviceName: String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        return "Mac"
        #elseif os(WASI)
        return "Web"
        #endif
    }

    /// Returns the main bundle's name if available (e.g. CodeEdit)
    static var copyrightString: String? {
        Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    }

    /// Returns the main bundle's version string if available (e.g. 1.0.0)
    static var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the main bundle's build string if available (e.g. 123)
    static var buildString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    /// Returns the version postfix if available (e.g. pre, dev, etc)
    static var versionPostfix: String? {
        Bundle.main.object(forInfoDictionaryKey: "CE_VERSION_POSTFIX") as? String
    }
}
