//
//  ExtensionSidebarItem.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/01/2023.
//

import Foundation
import CodeEditKit
import ExtensionFoundation

struct ExtensionSidebarItem: Identifiable, Hashable {
    var endpoint: AppExtensionIdentity
    var icon: String
    var sceneID: String

    var id: String {
        endpoint.bundleIdentifier + sceneID
    }

    init(endpoint: AppExtensionIdentity, icon: String, sceneID: String) {
        self.endpoint = endpoint
        self.icon = icon
        self.sceneID = sceneID
    }
}
