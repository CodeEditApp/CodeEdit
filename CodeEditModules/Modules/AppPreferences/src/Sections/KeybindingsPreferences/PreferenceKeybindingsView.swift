//
//  SwiftUIView.swift
//  
//
//  Created by Alex on 19.05.2022.
//

import SwiftUI

public struct PreferenceKeybindingsView: View {
    public init() {}

    public var body: some View {
        PreferencesContent {
            Text("Hello World")
        }
    }
}

struct PreferenceKeybindingsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceKeybindingsView()
    }
}
