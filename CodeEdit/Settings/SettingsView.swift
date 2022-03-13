//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
        }
        .frame(width: 450, height: 250)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
