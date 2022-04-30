//
//  TabBarItemRepresentable.swift
//  
//
//  Created by Pavel Kasila on 30.04.22.
//

import SwiftUI

public protocol TabBarItemRepresentable {
    var tabID: TabBarItemID { get }
    var title: String { get }
    var icon: Image { get }
    var iconColor: Color { get }
}
