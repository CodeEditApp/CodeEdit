//
//  SearchSettingsView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchSettingsView: View {

    @AppSettings(\.search.ignoreGlobPatterns)
    var ignoreGlobPatterns

    var body: some View {
        SettingsForm {
            Section {
                Text("No accounts")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } footer: {
                HStack {
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
    }
}
