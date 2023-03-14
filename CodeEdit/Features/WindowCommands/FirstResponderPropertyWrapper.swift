//
//  FirstResponderPropertyWrapper.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/03/2023.
//

import SwiftUI

@propertyWrapper
struct FirstResponder: DynamicProperty {
    @StateObject var helper = HelperClass()

    var wrappedValue: NSResponder? {
        helper.responder
    }

    class HelperClass: ObservableObject {
        @Published var responder: NSResponder? = NSApp.keyWindow?.firstResponder

        init() {
            NSApp.publisher(for: \.keyWindow?.firstResponder).assign(to: &$responder)
        }
    }
}
