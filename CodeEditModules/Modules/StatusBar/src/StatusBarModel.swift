//
//  StatusBarModel.swift
//  
//
//  Created by Lukas Pistrol on 20.03.22.
//

import Foundation

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

	// TODO: Add @Published vars for indentation, encoding, linebreak

	public init() {}
}
