//
//  GeneralPreferences.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

public extension AppPreferences {

    /// The general global setting
    struct GeneralPreferences: Codable {

        /// The appearance of the app
        public var appAppearance: Appearances = .system

        /// The style for file icons
        public var fileIconStyle: FileIconStyle = .color

        /// The reopen behavior of the app
        public var reopenBehavior: ReopenBehavior = .welcome

        public var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.appAppearance = try container.decodeIfPresent(Appearances.self, forKey: .appAppearance) ?? .system
            self.fileIconStyle = try container.decodeIfPresent(FileIconStyle.self, forKey: .fileIconStyle) ?? .color
            self.reopenBehavior = try container.decodeIfPresent(ReopenBehavior.self,
                                                                forKey: .reopenBehavior) ?? .welcome
            self.projectNavigatorSize = try container.decodeIfPresent(ProjectNavigatorSize.self,
                                                                                  forKey: .projectNavigatorSize)
            ?? .medium
        }
    }

    /// The appearance of the app
    /// - **system**: uses the system appearance
    /// - **dark**: always uses dark appearance
    /// - **light**: always uses light appearance
    enum Appearances: String, Codable {
        case system
        case light
        case dark

        /// Applies the selected appearance
        public func applyAppearance() {
            switch self {
            case .system:
                NSApp.appearance = nil

            case .dark:
                NSApp.appearance = .init(named: .darkAqua)

            case .light:
                NSApp.appearance = .init(named: .aqua)
            }
        }
    }

    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The reopen behavior of the app
    /// - **welcome**: On restart the app will show the welcome screen
    /// - **openPanel**: On restart the app will show an open panel
    /// - **newDocument**: On restart a new empty document will be created
    enum ReopenBehavior: String, Codable {
        case welcome
        case openPanel
        case newDocument
    }

    enum ProjectNavigatorSize: String, Codable {
        case small
        case medium
        case large
    }
}
