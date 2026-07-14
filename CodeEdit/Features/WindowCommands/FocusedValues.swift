//
//  FocusedValues.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 18/06/2023.
//

import SwiftUI

extension FocusedValues {
    var navigationSplitViewVisibility: Binding<NavigationSplitViewVisibility>? {
        get { self[NavSplitViewVisibilityFocusedValueKey.self] }
        set { self[NavSplitViewVisibilityFocusedValueKey.self] = newValue }
    }

    var inspectorVisibility: Binding<Bool>? {
        get { self[InspectorVisibilityFocusedValueKey.self] }
        set { self[InspectorVisibilityFocusedValueKey.self] = newValue }
    }

    private struct NavSplitViewVisibilityFocusedValueKey: FocusedValueKey {
        typealias Value = Binding<NavigationSplitViewVisibility>
    }

    private struct InspectorVisibilityFocusedValueKey: FocusedValueKey {
        typealias Value = Binding<Bool>
    }
}
