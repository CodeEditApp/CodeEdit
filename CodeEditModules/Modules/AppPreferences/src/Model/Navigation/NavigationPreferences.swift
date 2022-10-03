//
//  NavigationPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Aaryan Kothari on 04.10.22.
//

import SwiftUI

public extension AppPreferences {

    /// The general global setting
    struct NavigationPreferences: Codable {

        /// The appearance of the app
        public var activation: Bool = true

        /// The show issues behavior of the app
        public var fullScreen: Bool = true

        /// The show live issues behavior of the app
        public var commandClick: CommandClick = .selectCodeStructure

        /// The show file extensions behavior of the app
        public var optionClick: OptionClick = .quickHelp

        /// The file extensions collection to display
        public var navigationStyle: NavigationStyle = .inTabs

        /// The file extensions collection to hide
        public var navigation: Navigation = .focused

        /// The style for file icons
        public var optionalNavigation: OptionalNavigation = .nextEditor

        /// Choose between native-styled tab bar and Xcode-liked tab bar.
        public var doubleClickNavigation: DoubleClickNavigation = .tab

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.activation = try container.decodeIfPresent(
                Bool.self,
                forKey: .activation
            ) ?? true
            self.fullScreen = try container.decodeIfPresent(
                Bool.self,
                forKey: .fullScreen
            ) ?? true
            self.commandClick = try container.decodeIfPresent(
                CommandClick.self,
                forKey: .commandClick
            ) ?? .selectCodeStructure
            self.optionClick = try container.decodeIfPresent(
                OptionClick.self,
                forKey: .optionClick
            ) ?? .quickHelp
            self.navigationStyle = try container.decodeIfPresent(
                NavigationStyle.self,
                forKey: .navigationStyle
            ) ?? .inTabs
            self.navigation = try container.decodeIfPresent(
                Navigation.self,
                forKey: .navigation
            ) ?? .focused
            self.optionalNavigation = try container.decodeIfPresent(
                OptionalNavigation.self,
                forKey: .optionalNavigation
            ) ?? .nextEditor
            self.doubleClickNavigation = try container.decodeIfPresent(
                DoubleClickNavigation.self,
                forKey: .doubleClickNavigation
            ) ?? .tab
        }
        // swiftlint:enable function_body_length
    }

    /// The style for command-click on code
    ///  - **selectCodeStructure**: previews code structure
    ///  - **jumpToDefinition**: shows definition of structure
    enum CommandClick: Codable, Hashable, CaseIterable {
        case selectCodeStructure
        case jumpToDefinition

        var label: String {
            switch self {
            case .selectCodeStructure:
                return "Selects Code Structure"
            case .jumpToDefinition:
                return "Jumps to Definition"
            }
        }
    }

    /// The style for option-click on code
    ///  - **quickHelp**: opens quick help
    ///  - **swiftuiInspector**: opens swiftui inspector
    enum OptionClick: Codable, Hashable, CaseIterable {
        case quickHelp
        case swiftuiInspector

        var label: String {
            switch self {
            case .quickHelp:
                return "Shows Quick Help"
            case .swiftuiInspector:
                return "Shows SwiftUI Inspector"
            }
        }
    }

    /// The style for navigation style
    ///  - **inTabs**: opens file in new tab
    ///  - **inPlace**: opens file in existing tab
    enum NavigationStyle: Codable, Hashable, CaseIterable {
        case inTabs
        case inPlace

        var label: String {
            switch self {
            case .inTabs:
                return "Open in Tabs"
            case .inPlace:
                return "Open in Place"
            }
        }
    }

    /// The style for navigation
    ///  - **focused**: focued navigation
    ///  - **primary**: primary navigation
    enum Navigation: Codable, Hashable, CaseIterable {
        case focused
        case primary

        var label: String {
            switch self {
            case .focused:
                return "Uses Focused Editor"
            case .primary:
                return "Uses Primary Editor"
            }
        }
    }

    /// The style for optional navigation
    ///  - **nextEditor**: navigates to next editor
    ///  - **separateEditor**: navigates to separate editor
    ///  - **destinationChooser**: navigates to destination chooser
    ///  - **separateWindowTab**: navigates to new window tab
    ///  - **separateWindow**: navigates to separate window
    ///  - **tab**: navigatives to tab
    enum OptionalNavigation: Codable, Hashable, CaseIterable {
        case nextEditor
        case separateEditor
        case destinationChooser
        case separateWindowTab
        case separateWindow
        case tab

        var label: String {
            switch self {
            case .nextEditor:
                return "Uses Next Editor"
            case .separateEditor:
                return "Uses Separate Editor"
            case .destinationChooser:
                return "Uses Destination Editor"
            case .separateWindowTab:
                return "Uses Separate Window Tab"
            case .separateWindow:
                return "Uses Separate Window"
            case .tab:
                return "Uses Tab"
            }
        }
    }

    /// The style for double click navigation
    ///  - **separateWindowTab**: navigates to new window tab
    ///  - **separateWindow**: navigates to separate window
    ///  - **sameAsClick**: navigates same as click
    ///  - **tab**: navigatives to tab
    enum DoubleClickNavigation: Codable, Hashable, CaseIterable {
        case separateWindowTab
        case separateWindow
        case sameAsClick
        case tab

        var label: String {
            switch self {
            case .separateWindowTab:
                return "Uses Separate Window Tab"
            case .separateWindow:
                return "Uses Separate Window"
            case .sameAsClick:
                return "Same as Click"
            case .tab:
                return "Uses Tab"
            }
        }
    }
}
