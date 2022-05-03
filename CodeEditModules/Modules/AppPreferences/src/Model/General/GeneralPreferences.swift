//
//  GeneralPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

public extension AppPreferences {

    /// The general global setting
    struct GeneralPreferences: Codable {

        /// The appearance of the app
        public var appAppearance: Appearances = .system

        /// The show issues behavior of the app
        public var showIssues: Issues = .inline

        /// The show live issues behavior of the app
        public var showLiveIssues: Bool = true

        /// The show file extensions behavior of the app
        public var fileExtensions: FileExtensions = .showAll

        /// The style for file icons
        public var fileIconStyle: FileIconStyle = .color

        /// Choose between native-styled tab bar and Xcode-liked tab bar.
        public var tabBarStyle: TabBarStyle = .xcode

        /// The reopen behavior of the app
        public var reopenBehavior: ReopenBehavior = .welcome

        public var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// The Find Navigator Detail line limit
        public var findNavigatorDetail: NavigatorDetail = .upTo3

        /// The Issue Navigator Detail line limit
        public var issueNavigatorDetail: NavigatorDetail = .upTo3

        /// Default initializer
        public init() {}

        // swiftlint:disable function_body_length
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.appAppearance = try container.decodeIfPresent(
                Appearances.self,
                forKey: .appAppearance
            ) ?? .system
            self.showIssues = try container.decodeIfPresent(
                Issues.self,
                forKey: .showIssues
            ) ?? .inline
            self.showLiveIssues = try container.decodeIfPresent(
                Bool.self,
                forKey: .showLiveIssues
            ) ?? true
            self.fileExtensions = try container.decodeIfPresent(
                FileExtensions.self,
                forKey: .fileExtensions
            ) ?? .showAll
            self.fileIconStyle = try container.decodeIfPresent(
                FileIconStyle.self,
                forKey: .fileIconStyle
            ) ?? .color
            self.tabBarStyle = try container.decodeIfPresent(
                TabBarStyle.self,
                forKey: .tabBarStyle
            ) ?? .xcode
            self.reopenBehavior = try container.decodeIfPresent(
                ReopenBehavior.self,
                forKey: .reopenBehavior
            ) ?? .welcome
            self.projectNavigatorSize = try container.decodeIfPresent(
                ProjectNavigatorSize.self,
                forKey: .projectNavigatorSize
            ) ?? .medium
            self.findNavigatorDetail = try container.decodeIfPresent(
                NavigatorDetail.self,
                forKey: .findNavigatorDetail
            ) ?? .upTo3
            self.issueNavigatorDetail = try container.decodeIfPresent(
                NavigatorDetail.self,
                forKey: .issueNavigatorDetail
            ) ?? .upTo3
        }
        // swiftlint:enable function_body_length
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

    /// The style for issues display
    ///  - **inline**: Issues show inline
    ///  - **minimized** Issues show minimized
    enum Issues: String, Codable {
        case inline
        case minimized
    }

    /// The style for file extensions display
    ///  - **hideAll**: File extensions are hidden
    ///  - **showAll** File extensions are visible
    ///  - **showOnly** Display specified file extensions
    enum FileExtensions: String, Codable {
        case hideAll
        case showAll
        case showOnly
    }
    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The style for tab bar
    /// - **native**: Native-styled tab bar (like Finder)
    /// - **xcode**: Xcode-liked tab bar
    enum TabBarStyle: String, Codable {
        case native
        case xcode
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

    /// The Navigation Detail behavior of the app
    ///  - Use **rawValue** to set lineLimit
    enum NavigatorDetail: Int, Codable, CaseIterable {
        case upTo1 = 1
        case upTo2 = 2
        case upTo3 = 3
        case upTo4 = 4
        case upTo5 = 5
        case upTo10 = 10
        case upTo30 = 30

        var label: String {
            switch self {
            case .upTo1:
                return "One Line"
            default:
                return "Up to \(self.rawValue) lines"
            }
        }
    }
}
