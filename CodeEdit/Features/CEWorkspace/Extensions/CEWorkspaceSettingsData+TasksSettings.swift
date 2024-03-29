//
//  CEWorkspaceSettingsData+TasksSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation

extension CEWorkspaceSettingsData {

	/// The general global setting
	struct TasksSettings: Codable, Hashable, SearchableSettingsPage {

		/// The appearance of the app
		var appAppearance: Appearances = .system

		/// The show issues behavior of the app
		var showIssues: Issues = .inline

		/// The show live issues behavior of the app
		var showLiveIssues: Bool = true

		/// The search keys
		var searchKeys: [String] {
			[
				"Appearance",
				"File Icon Style",
				"Tab Bar Style",
				"Show Path Bar",
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

		/// Show editor path bar
		var showEditorPathBar: Bool = true

		/// Dims editors without focus
		var dimEditorsWithoutFocus: Bool = false

		/// The show file extensions behavior of the app
		var fileExtensionsVisibility: FileExtensionsVisibility = .showAll

		/// The file extensions collection to display
		var shownFileExtensions: FileExtensions = .default

		/// The file extensions collection to hide
		var hiddenFileExtensions: FileExtensions = .default

		/// The style for file icons
		var fileIconStyle: FileIconStyle = .color

		/// Choose between native-styled tab bar and Xcode-liked tab bar.
		var tabBarStyle: TabBarStyle = .xcode

		/// The position for the navigator sidebar tab bar
		var navigatorTabBarPosition: SidebarTabBarPosition = .top

		/// The position for the inspector sidebar tab bar
		var inspectorTabBarPosition: SidebarTabBarPosition = .top

		/// The reopen behavior of the app
		var reopenBehavior: ReopenBehavior = .welcome

		/// Decides what the app does after a workspace is closed
		var reopenWindowAfterClose: ReopenWindowBehavior = .doNothing

		/// The size of the project navigator
		var projectNavigatorSize: ProjectNavigatorSize = .medium

		/// The Find Navigator Detail line limit
		var findNavigatorDetail: NavigatorDetail = .upTo3

		/// The Issue Navigator Detail line limit
		var issueNavigatorDetail: NavigatorDetail = .upTo3

		/// The reveal file in navigator when focus changes behavior of the app.
		var revealFileOnFocusChange: Bool = false

		/// Auto save behavior toggle
		var isAutoSaveOn: Bool = true

		/// Default initializer
		init() {}

		// swiftlint:disable function_body_length
		/// Explicit decoder init for setting default values when key is not present in `JSON`
		init(from decoder: Decoder) throws {
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
			self.showEditorPathBar = try container.decodeIfPresent(
				Bool.self,
				forKey: .showEditorPathBar
			) ?? true
			self.dimEditorsWithoutFocus = try container.decodeIfPresent(
				Bool.self,
				forKey: .dimEditorsWithoutFocus
			) ?? false
			self.fileExtensionsVisibility = try container.decodeIfPresent(
				FileExtensionsVisibility.self,
				forKey: .fileExtensionsVisibility
			) ?? .showAll
			self.shownFileExtensions = try container.decodeIfPresent(
				FileExtensions.self,
				forKey: .shownFileExtensions
			) ?? .default
			self.hiddenFileExtensions = try container.decodeIfPresent(
				FileExtensions.self,
				forKey: .hiddenFileExtensions
			) ?? .default
			self.fileIconStyle = try container.decodeIfPresent(
				FileIconStyle.self,
				forKey: .fileIconStyle
			) ?? .color
			self.tabBarStyle = try container.decodeIfPresent(
				TabBarStyle.self,
				forKey: .tabBarStyle
			) ?? .xcode
			self.navigatorTabBarPosition = try container.decodeIfPresent(
				SidebarTabBarPosition.self,
				forKey: .navigatorTabBarPosition
			) ?? .top
			self.inspectorTabBarPosition = try container.decodeIfPresent(
				SidebarTabBarPosition.self,
				forKey: .inspectorTabBarPosition
			) ?? .top
			self.reopenBehavior = try container.decodeIfPresent(
				ReopenBehavior.self,
				forKey: .reopenBehavior
			) ?? .welcome
			self.reopenWindowAfterClose = try container.decodeIfPresent(
				ReopenWindowBehavior.self,
				forKey: .reopenWindowAfterClose
			) ?? .doNothing
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
			self.revealFileOnFocusChange = try container.decodeIfPresent(
				Bool.self,
				forKey: .revealFileOnFocusChange
			) ?? false
			self.isAutoSaveOn = try container.decodeIfPresent(
				Bool.self,
				forKey: .isAutoSaveOn
			) ?? true
		}
		// swiftlint:enable function_body_length
	}
}
