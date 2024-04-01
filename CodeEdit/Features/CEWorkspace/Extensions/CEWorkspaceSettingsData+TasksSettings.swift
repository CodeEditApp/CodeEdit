//
//  CEWorkspaceSettingsData+TasksSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation

extension CEWorkspaceSettingsData {

	/// The tasks  setting
	struct TasksSettings: Codable, Hashable, SearchableSettingsPage {
		/// The show live issues behavior of the app
		var tasksEnabled: Bool = true

		/// Default initializer
		init() {}

		// swiftlint:disable function_body_length
		/// Explicit decoder init for setting default values when key is not present in `JSON`
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self
			self.tasksEnabled = try container.decodeIfPresent(
				Bool.self,
				forKey: .tasksEnabled
			) ?? true
		}
		// swiftlint:enable function_body_length
	}
}
