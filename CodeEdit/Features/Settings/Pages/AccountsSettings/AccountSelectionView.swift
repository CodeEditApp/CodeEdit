//
//  AccoundSelectionView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/5/23.
//

import SwiftUI

struct AccountSelectionView: View {
    @Environment(\.dismiss)
    var dismiss

    @Binding var selectedProvider: SourceControlAccount.Provider?

    var gitProviders = SourceControlAccount.Provider.allCases

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(gitProviders, id: \.self) { provider in
                            AccountsSettingsProviderRow(
                                name: provider.name,
                                iconName: provider.iconName,
                                action: {
                                    selectedProvider = provider
                                    dismiss()
                                }
                            )
                            Divider()
                        }
                    }
                    .padding(-10)
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
