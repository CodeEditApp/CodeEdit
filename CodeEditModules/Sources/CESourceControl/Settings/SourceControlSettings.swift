//
//  SourceControlPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import CodeEditSettings
import Foundation

/// The global settings for source control
public struct SourceControlSettings: SettingsSection {

    /// The top-level key this section occupies in `settings.json`.
    public static let settingsKey = "sourceControl"

    /// The general source control settings
    public var general: SourceControlGeneral = .init()

    /// The source control git settings
    public var git: SourceControlGit = .init()

    /// Default initializer
    public init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.general = try container.decodeIfPresent(SourceControlGeneral.self, forKey: .general) ?? .init()
        self.git = try container.decodeIfPresent(SourceControlGit.self, forKey: .git) ?? .init()
    }

    public struct SourceControlGeneral: Codable, Hashable {
        /// Indicates whether or not the source control is active
        public var sourceControlIsEnabled: Bool = true
        /// Indicates whether the status should be refreshed locally without fetching updates from the server.
        public var refreshStatusLocally: Bool = true
        /// Indicates whether the application should automatically fetch updates from the server and refresh the status.
        public var fetchRefreshServerStatus: Bool = true
        /// Indicates whether new and deleted files should be automatically staged for commit.
        public var addRemoveAutomatically: Bool = true
        /// Indicates whether the application should automatically select files to commit.
        public var selectFilesToCommit: Bool = true
        /// Indicates whether or not to show the source control changes
        public var showSourceControlChanges: Bool = true
        /// Indicates whether or not we should include the upstream
        public var includeUpstreamChanges: Bool = true
        /// Indicates whether or not we should open the reported feedback in the browser
        public var openFeedbackInBrowser: Bool = true
        /// The selected value of the comparison view
        public var revisionComparisonLayout: RevisionComparisonLayout = .localLeft
        /// The selected value of the control navigator
        public var controlNavigatorOrder: ControlNavigatorOrder = .sortByName
        /// Default initializer
        public init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sourceControlIsEnabled = try container.decodeIfPresent(
                Bool.self,
                forKey: .sourceControlIsEnabled
            ) ?? true
            self.refreshStatusLocally = try container.decodeIfPresent(Bool.self, forKey: .refreshStatusLocally) ?? true
            self.fetchRefreshServerStatus = try container.decodeIfPresent(
                Bool.self,
                forKey: .fetchRefreshServerStatus
            ) ?? true
            self.addRemoveAutomatically = try container.decodeIfPresent(
                Bool.self,
                forKey: .addRemoveAutomatically
            ) ?? true
            self.selectFilesToCommit = try container.decodeIfPresent(Bool.self, forKey: .selectFilesToCommit) ?? true
            self.showSourceControlChanges = try container.decodeIfPresent(
                Bool.self,
                forKey: .showSourceControlChanges
            ) ?? true
            self.includeUpstreamChanges = try container.decodeIfPresent(
                Bool.self,
                forKey: .includeUpstreamChanges
            ) ?? true
            self.openFeedbackInBrowser = try container.decodeIfPresent(
                Bool.self,
                forKey: .openFeedbackInBrowser
            ) ?? true
            self.revisionComparisonLayout = try container.decodeIfPresent(
                RevisionComparisonLayout.self,
                forKey: .revisionComparisonLayout
            ) ?? .localLeft
            self.controlNavigatorOrder = try container.decodeIfPresent(
                ControlNavigatorOrder.self,
                forKey: .controlNavigatorOrder
            ) ?? .sortByName
        }
    }

    /// The style for comparison View
    /// - **localLeft**: Local Revision on Left Side
    /// - **localRight**: Local Revision on Right Side
    public enum RevisionComparisonLayout: String, Codable {
        case localLeft
        case localRight
    }

    /// The style for control Navigator
    /// - **sortName**: They are sorted by Name
    /// - **sortDate**: They are sorted by Date
    public enum ControlNavigatorOrder: String, Codable {
        case sortByName
        case sortByDate
    }

    public struct SourceControlGit: Codable, Hashable {
        /// Indicates whether we should rebase when pulling commits
        public var showMergeCommitsPerFileLog: Bool = false
        /// Default initializer
        public init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showMergeCommitsPerFileLog = try container.decodeIfPresent(
                Bool.self,
                forKey: .showMergeCommitsPerFileLog
            ) ?? false
        }
    }
}
