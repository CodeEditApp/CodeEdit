//
//  SearchSettingsIgnoreGlobPatternAddView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchSettingsIgnoreGlobPatternAddView: View {
    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Add here!")
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.top, 10)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
        }
        .frame(width: 300)
    }
}
