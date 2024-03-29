//
//  CEWorkpaceSettingsSearchResult.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation
import SwiftUI

// TODO: Extend this struct further to support setting "flashing"
class CEWorkspaceSettingsSearchResult: Identifiable {
	init(
		pageFound: Bool,
		pages: [CEWorkspaceSettingsPage]
	) {
		self.pageFound = pageFound
		self.pages = pages
	}

	let id: UUID = UUID()

	let pageFound: Bool
	let pages: [CEWorkspaceSettingsPage]
}
