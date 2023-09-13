//
//  EditorTabRepresentable.swift
//  
//
//  Created by Pavel Kasila on 30.04.22.
//

import SwiftUI

/// Protocol for data passed to EditorTabView to conform to
protocol EditorTabRepresentable {
    /// Unique tab identifier
    var tabID: EditorTabID { get }
    /// String to be shown as tab's title
    var name: String { get }
    /// Image to be shown as tab's icon
    var icon: Image { get }
    /// Color of the tab's icon
    var iconColor: Color { get }
}
