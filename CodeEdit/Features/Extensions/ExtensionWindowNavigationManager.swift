//
//  ExtensionWindowNavigationManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/01/2023.
//

import SwiftUI

class ExtensionWindowNavigationManager: ObservableObject {
    @Published var installedSelection = Set<ExtensionInfo>()
    @Published var storeCategorySelection = StoreCategories.suggestions
}
