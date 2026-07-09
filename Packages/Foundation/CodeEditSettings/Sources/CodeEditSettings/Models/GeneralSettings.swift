//
//  GeneralSettings.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

extension SettingsData {

    /// The general global setting
    public struct GeneralSettings: Codable, Hashable {

        /// The appearance of the app
        @CodableDefault<DefaultAppearance> public var appAppearance: Appearances = .system

        /// The show issues behavior of the app
        @CodableDefault<DefaultIssues> public var showIssues: Issues = .inline

        /// The show live issues behavior of the app
        @CodableDefault<DefaultTrue> public var showLiveIssues = true

        /// Show editor jump bar
        @CodableDefault<DefaultTrue> public var showEditorJumpBar = true

        /// Dims editors without focus
        @CodableDefault<DefaultFalse> public var dimEditorsWithoutFocus = false

        /// The show file extensions behavior of the app
        @CodableDefault<DefaultFileExtensionsVisibility> public var fileExtensionsVisibility: FileExtensionsVisibility = .showAll

        /// The file extensions collection to display
        @CodableDefault<DefaultFileExtensions> public var shownFileExtensions: FileExtensions = .default

        /// The file extensions collection to hide
        @CodableDefault<DefaultFileExtensions> public var hiddenFileExtensions: FileExtensions = .default

        /// The style for file icons
        @CodableDefault<DefaultFileIconStyle> public var fileIconStyle: FileIconStyle = .color

        /// The position for the navigator sidebar tab bar
        @CodableDefault<DefaultSidebarTabBarPositionTop> public var navigatorTabBarPosition: SidebarTabBarPosition = .top

        /// The position for the inspector sidebar tab bar
        @CodableDefault<DefaultSidebarTabBarPositionTop> public var inspectorTabBarPosition: SidebarTabBarPosition = .top

        /// The reopen behavior of the app
        @CodableDefault<DefaultReopenBehavior> public var reopenBehavior: ReopenBehavior = .welcome

        /// Decides what the app does after a workspace is closed
        @CodableDefault<DefaultReopenWindowBehavior> public var reopenWindowAfterClose: ReopenWindowBehavior = .doNothing

        /// The size of the project navigator
        @CodableDefault<DefaultProjectNavigatorSize> public var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// The Find Navigator Detail line limit
        @CodableDefault<DefaultNavigatorDetail> public var findNavigatorDetail: NavigatorDetail = .upTo3

        /// The Issue Navigator Detail line limit
        @CodableDefault<DefaultNavigatorDetail> public var issueNavigatorDetail: NavigatorDetail = .upTo3

        /// The reveal file in navigator when focus changes behavior of the app.
        @CodableDefault<DefaultFalse> public var revealFileOnFocusChange = false

        /// Auto save behavior toggle
        @CodableDefault<DefaultTrue> public var isAutoSaveOn = true

        /// Default initializer
        public init() {}
    }

    /// The appearance of the app
    /// - **system**: uses the system appearance
    /// - **dark**: always uses dark appearance
    /// - **light**: always uses light appearance
    public enum Appearances: String, Codable {
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
    public enum Issues: String, Codable {
        case inline
        case minimized
    }

    /// The style for file extensions visibility
    ///  - **hideAll**: File extensions are hidden
    ///  - **showAll** File extensions are visible
    ///  - **showOnly** Specific file extensions are visible
    ///  - **hideOnly** Specific file extensions are hidden
    public enum FileExtensionsVisibility: Codable, Hashable {
        case hideAll
        case showAll
        case showOnly
        case hideOnly
    }

    /// The collection of file extensions used by
    /// ``FileExtensionsVisibility/showOnly`` or  ``FileExtensionsVisibility/hideOnly`` preference
    public struct FileExtensions: Codable, Hashable {
        public var extensions: [String]

        public var string: String {
            get {
                extensions.joined(separator: ", ")
            }
            set {
                extensions = newValue
                    .components(separatedBy: ",")
                    .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                    .filter({ !$0.isEmpty || string.count < newValue.count })
            }
        }

        nonisolated(unsafe) public static var `default` = FileExtensions(extensions: [
            "c", "cc", "cpp", "h", "hpp", "m", "mm", "gif",
            "icns", "jpeg", "jpg", "png", "tiff", "swift"
        ])
    }
    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    public enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The position for a sidebar tab bar
    /// - **top**: Tab bar is positioned at the top of the sidebar
    /// - **side**: Tab bar is positioned to the side of the sidebar
    public enum SidebarTabBarPosition: String, Codable {
        case top, side
    }

    /// The reopen behavior of the app
    /// - **welcome**: On restart the app will show the welcome screen
    /// - **openPanel**: On restart the app will show an open panel
    /// - **newDocument**: On restart a new empty document will be created
    public enum ReopenBehavior: String, Codable {
        case welcome
        case openPanel
        case newDocument
    }

    public enum ReopenWindowBehavior: String, Codable {
        case showWelcomeWindow
        case doNothing
        case quit
    }

    public enum ProjectNavigatorSize: String, Codable {
        case small
        case medium
        case large

        /// Returns the row height depending on the `projectNavigatorSize` in `Settings`.
        ///
        /// * `small`: 20
        /// * `medium`: 22
        /// * `large`: 24
        public var rowHeight: Double {
            switch self {
            case .small: return 20
            case .medium: return 22
            case .large: return 24
            }
        }
    }

    /// The Navigation Detail behavior of the app
    ///  - Use **rawValue** to set lineLimit
    public enum NavigatorDetail: Int, Codable, CaseIterable {
        case upTo1 = 1
        case upTo2 = 2
        case upTo3 = 3
        case upTo4 = 4
        case upTo5 = 5
        case upTo10 = 10
        case upTo30 = 30

        public var label: String {
            switch self {
            case .upTo1:
                return "One Line"
            default:
                return "Up to \(self.rawValue) lines"
            }
        }
    }
}
