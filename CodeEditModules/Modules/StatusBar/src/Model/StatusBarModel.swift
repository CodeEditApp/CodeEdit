//
//  StatusBarModel.swift
//  
//
//  Created by Lukas Pistrol on 20.03.22.
//

import SwiftUI
import GitClient

public class StatusBarModel: ObservableObject {

	// TODO: Implement logic for updating values
	@Published public var errorCount: Int = 0 // Implementation missing
	@Published public var warningCount: Int = 0 // Implementation missing

	@Published public var branches: [String] = ["main"] // Implementation missing
	@Published public var selectedBranch: String = "" // Implementation missing

	@Published public var isReloading: Bool = false // Implementation missing

	@Published public var currentLine: Int = 1 // Implementation missing
	@Published public var currentCol: Int = 1 // Implementation missing

	@Published public var isExpanded: Bool = false // Implementation missing

	@Published public var currentHeight: Double = 0
	@Published public var isDragging: Bool = false

	private (set) var toolbarFont: Font = .system(size: 11)

	private (set) var gitClient: GitClient

	private (set) var maxHeight: Double = 500
	private (set) var standardHeight: Double = 300
	private (set) var minHeight: Double = 100

	// TODO: Add @Published vars for indentation, encoding, linebreak

	public init(gitClient: GitClient) {
		self.gitClient = gitClient
		self.selectedBranch = gitClient.getCurrentBranchName()
	}
}
