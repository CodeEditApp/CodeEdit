//
//  ExtensionNavigator.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI

struct ExtensionNavigator: View {
    var body: some View {
        List {
            Text("Extensions")
        }
        .listStyle(.sidebar)
        .listRowInsets(.init())
    }
}

struct ExtensionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionNavigator()
    }
}
