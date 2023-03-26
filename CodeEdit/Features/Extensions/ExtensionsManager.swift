//
//  ExtensionManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import Foundation
import SwiftUI
import ExtensionFoundation
import CodeEditKit
import ConcurrencyPlus

final class ExtensionManager: ObservableObject {

    static var shared = ExtensionManager()

    @Published var extensions: [ExtensionInfo] = []

    init() {
        ExtensionDiscovery.shared.$extensions.assign(to: &$extensions)
    }

}
