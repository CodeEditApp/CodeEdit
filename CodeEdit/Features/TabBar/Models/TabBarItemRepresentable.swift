//
//  TabBarTabRepresentable.swift
//  
//
//  Created by Pavel Kasila on 30.04.22.
//

import SwiftUI

/// Protocol for data passed to TabBarTabView to conform to
protocol TabBarTabRepresentable {
    /// Unique tab identifier
    var tabID: TabBarTabID { get }
    /// String to be shown as tab's title
    var name: String { get }
    /// Image to be shown as tab's icon
    var icon: Image { get }
    /// Color of the tab's icon
    var iconColor: Color { get }
}
