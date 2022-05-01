//
//  SourceControlPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

public extension AppPreferences {
    /// The global settings for source control
    struct SourceControlPreferences: Codable {
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
    }

    struct SourceControlGeneral: Codable {
        /// Indicates whether or not the source control is active
        public var enableSourceControl: Bool = true
        /// Indicates whether or not we should include the upsteam changes
        public var refreshStatusLocaly: Bool = false
        /// Indicates whether or not we should include the upsteam changes
        public var fetchRefreshServerStatus: Bool = false
        /// Indicates whether or not we should include the upsteam changes
        public var addRemoveAutomatically: Bool = false
        /// Indicates whether or not we should include the upsteam changes
        public var selectFilesToCommit: Bool = false
        /// Indicates whether or not to show the source control changes
        public var showSourceControlChanges: Bool = true
        /// Indicates whether or not we should include the upsteam
        public var includeUpstreamChanges: Bool = false
        /// Indicates whether or not we should open the reported feedback in the browser
        public var openFeedbackInBrowser: Bool = true
        /// The selected value of the comparison view
        public var revisionComparisonLayout: RevisionComparisonLayout = .localLeft
        /// The selected value of the control navigator
        public var controlNavigatorOrder: ControlNavigatorOrder = .sortByName
        /// The name of the default branch
        public var defaultBranchName: String = "main"
        /// Default initializer
        public init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.enableSourceControl = try container.decodeIfPresent(Bool.self, forKey: .enableSourceControl) ?? true
            self.refreshStatusLocaly = try container.decodeIfPresent(Bool.self, forKey: .refreshStatusLocaly) ?? true
            self.fetchRefreshServerStatus = try container.decodeIfPresent(Bool.self,
                                                                          forKey: .fetchRefreshServerStatus) ?? true
            self.addRemoveAutomatically = try container.decodeIfPresent(Bool.self,
                                                                        forKey: .addRemoveAutomatically) ?? true
            self.selectFilesToCommit = try container.decodeIfPresent(Bool.self, forKey: .selectFilesToCommit) ?? true
            self.showSourceControlChanges = try container.decodeIfPresent(Bool.self,
                                                                          forKey: .showSourceControlChanges) ?? true
            self.includeUpstreamChanges = try container.decodeIfPresent(Bool.self,
                                                                        forKey: .includeUpstreamChanges) ?? true
            self.openFeedbackInBrowser = try container.decodeIfPresent(Bool.self,
                                                                        forKey: .openFeedbackInBrowser) ?? true
            self.revisionComparisonLayout = try container.decodeIfPresent(RevisionComparisonLayout.self,
                                                                forKey: .revisionComparisonLayout) ?? .localLeft
            self.controlNavigatorOrder = try container.decodeIfPresent(ControlNavigatorOrder.self,
                                                                  forKey: .controlNavigatorOrder) ?? .sortByName
            self.defaultBranchName = try container.decodeIfPresent(String.self, forKey: .defaultBranchName) ?? "main"
        }
    }

    /// The style for comparison View
    /// - **localLeft**: Local Revision on Left Side
    /// - **localRight**: Local Revision on Right Side
    enum RevisionComparisonLayout: String, Codable {
        case localLeft
        case localRight
    }

    /// The style for control Navigator
    /// - **sortName**: They are sorted by Name
    /// - **sortDate**: They are sorted by Date
    enum ControlNavigatorOrder: String, Codable {
        case sortByName
        case sortByDate
    }

    struct SourceControlGit: Codable {
        /// The author name
        public var authorName: String = ""
        /// The author email
        public var authorEmail: String = ""
        /// Indicates what files should be ignored when commiting
        public var ignoredFiles: [IgnoredFiles] = []
        /// Indicates whether we should rebase when pulling commits
        public var preferRebaseWhenPulling: Bool = false
        /// Indicates whether we should show commits per file log
        public var showMergeCommitsPerFileLog: Bool = false
        /// Default initializer
        public init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.authorName = try container.decodeIfPresent(String.self, forKey: .authorName) ?? ""
            self.authorEmail = try container.decodeIfPresent(String.self, forKey: .authorEmail) ?? ""
            self.ignoredFiles = try container.decodeIfPresent([IgnoredFiles].self,
                                                              forKey: .ignoredFiles) ?? []
            self.preferRebaseWhenPulling = try container.decodeIfPresent(Bool.self,
                                                                         forKey: .preferRebaseWhenPulling) ?? false
            self.showMergeCommitsPerFileLog = try container.decodeIfPresent(Bool.self,
                                                                        forKey: .showMergeCommitsPerFileLog) ?? false
        }
    }
}
