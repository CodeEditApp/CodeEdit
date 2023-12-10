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
    
    @State private var addIgnoreGlobPatternPresented: Bool = false

    var body: some View {
        SettingsForm {
            Section {
                if $ignoreGlobPatterns.isEmpty {
                    Text("No ignore patterns")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach($ignoreGlobPatterns, id: \.self) { pattern in
                        SearchSettingsIgnoreGlobPatternItemView(globPattern: pattern)
                    }
                }
            } footer: {
                HStack {
                    Spacer()
                    Button("Add ignore glob pattern...") { addIgnoreGlobPatternPresented.toggle() }
                    .sheet(isPresented: $addIgnoreGlobPatternPresented, content: {
                        SearchSettingsIgnoreGlobPatternAddView()
                    })
                }
                .padding(.top, 10)
            }
        }
    }
}
