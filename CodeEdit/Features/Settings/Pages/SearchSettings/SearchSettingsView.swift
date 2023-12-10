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
                if $ignoreGlobPatterns.isEmpty {
                    Text("No ignore patterns")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach($ignoreGlobPatterns, id: \.self) { pattern in
                        SearchIgnoreGlobPattern(globPattern: pattern)
                    }
                }
            } footer: {
                HStack {
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
    }
}
