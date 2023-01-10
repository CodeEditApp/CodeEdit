//
//  ExtensionWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import SwiftUI
import WindowManagement

struct ExtensionWindow: Scene {

    var body: some Scene {
        Window("Extensions", id: "Extensions") {
            ExtensionWindowContentView()
                .environmentObject(ExtensionDiscovery.shared)
        }
        .register("Extensions")
        .collectionBehavior(.canJoinAllSpaces)
    }

}
