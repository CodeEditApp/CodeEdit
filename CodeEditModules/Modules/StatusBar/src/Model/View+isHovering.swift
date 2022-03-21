//
//  View+isHovering.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal extension View {
	func isHovering(_ active: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
		if isDragging { return }
		if active {
			cursor.push()
		} else {
			NSCursor.pop()
		}
	}
}
