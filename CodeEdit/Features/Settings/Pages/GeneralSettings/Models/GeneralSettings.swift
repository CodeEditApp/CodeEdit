//
//  GeneralSettings.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

extension SettingsData {

    /// The general global setting
    struct GeneralSettings: Codable, Hashable, SearchableSettingsPage {

        /// The appearance of the app
        @CodableDefault<DefaultAppearance> var appAppearance: Appearances = .system

        /// The show issues behavior of the app
        @CodableDefault<DefaultIssues> var showIssues: Issues = .inline

        /// The show live issues behavior of the app
        @CodableDefault<DefaultTrue> var showLiveIssues = true

        /// The search keys
        var searchKeys: [String] {
            [
                "Appearance",
                "File Icon Style",
                "Tab Bar Style",
                "Show Jump Bar",
                "Dim editors without focus",
                "Navigator Tab Bar Position",
                "Inspector Tab Bar Position",
                "Show Issues",
                "Show Live Issues",
                "Automatically save change to disk",
                "Automatically reveal in project navigator",
                "Reopen Behavior",
                "After the last window is closed",
                "File Extensions",
                "Project Navigator Size",
                "Find Navigator Detail",
                "Issue Navigator Detail",
                "Show “Open With CodeEdit“ option in Finder",
                "'codeedit' Shell command",
                "Dialog Warnings",
                "Check for updates",
                "Automatically check for app updates",
                "Include pre-release versions"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Show editor jump bar
        @CodableDefault<DefaultTrue> var showEditorJumpBar = true

        /// Dims editors without focus
        @CodableDefault<DefaultFalse> var dimEditorsWithoutFocus = false

        /// The show file extensions behavior of the app
        @CodableDefault<DefaultFileExtensionsVisibility> var fileExtensionsVisibility: FileExtensionsVisibility = .showAll

        /// The file extensions collection to display
        @CodableDefault<DefaultFileExtensions> var shownFileExtensions: FileExtensions = .default

        /// The file extensions collection to hide
        @CodableDefault<DefaultFileExtensions> var hiddenFileExtensions: FileExtensions = .default

        /// The style for file icons
        @CodableDefault<DefaultFileIconStyle> var fileIconStyle: FileIconStyle = .color

        /// The position for the navigator sidebar tab bar
        @CodableDefault<DefaultSidebarTabBarPositionTop> var navigatorTabBarPosition: SidebarTabBarPosition = .top

        /// The position for the inspector sidebar tab bar
        @CodableDefault<DefaultSidebarTabBarPositionTop> var inspectorTabBarPosition: SidebarTabBarPosition = .top

        /// The reopen behavior of the app
        @CodableDefault<DefaultReopenBehavior> var reopenBehavior: ReopenBehavior = .welcome

        /// Decides what the app does after a workspace is closed
        @CodableDefault<DefaultReopenWindowBehavior> var reopenWindowAfterClose: ReopenWindowBehavior = .doNothing

        /// The size of the project navigator
        @CodableDefault<DefaultProjectNavigatorSize> var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// The Find Navigator Detail line limit
        @CodableDefault<DefaultNavigatorDetail> var findNavigatorDetail: NavigatorDetail = .upTo3

        /// The Issue Navigator Detail line limit
        @CodableDefault<DefaultNavigatorDetail> var issueNavigatorDetail: NavigatorDetail = .upTo3

        /// The reveal file in navigator when focus changes behavior of the app.
        @CodableDefault<DefaultFalse> var revealFileOnFocusChange = false

        /// Auto save behavior toggle
        @CodableDefault<DefaultTrue> var isAutoSaveOn = true

        /// Default initializer
        init() {}
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
        func applyAppearance() {
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

    /// The style for file extensions visibility
    ///  - **hideAll**: File extensions are hidden
    ///  - **showAll** File extensions are visible
    ///  - **showOnly** Specific file extensions are visible
    ///  - **hideOnly** Specific file extensions are hidden
    enum FileExtensionsVisibility: Codable, Hashable {
        case hideAll
        case showAll
        case showOnly
        case hideOnly
    }

    /// The collection of file extensions used by
    /// ``FileExtensionsVisibility/showOnly`` or  ``FileExtensionsVisibility/hideOnly`` preference
    struct FileExtensions: Codable, Hashable {
        var extensions: [String]

        var string: String {
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

        static var `default` = FileExtensions(extensions: [
            "c", "cc", "cpp", "h", "hpp", "m", "mm", "gif",
            "icns", "jpeg", "jpg", "png", "tiff", "swift"
        ])
    }
    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The position for a sidebar tab bar
    /// - **top**: Tab bar is positioned at the top of the sidebar
    /// - **side**: Tab bar is positioned to the side of the sidebar
    enum SidebarTabBarPosition: String, Codable {
        case top, side
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

    enum ReopenWindowBehavior: String, Codable {
        case showWelcomeWindow
        case doNothing
        case quit
    }

    enum ProjectNavigatorSize: String, Codable {
        case small
        case medium
        case large

        /// Returns the row height depending on the `projectNavigatorSize` in `Settings`.
        ///
        /// * `small`: 20
        /// * `medium`: 22
        /// * `large`: 24
        var rowHeight: Double {
            switch self {
            case .small: return 20
            case .medium: return 22
            case .large: return 24
            }
        }
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
