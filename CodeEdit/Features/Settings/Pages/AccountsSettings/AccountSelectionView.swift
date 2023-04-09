//
//  AccoundSelectionView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/5/23.
//

import SwiftUI

struct AccountSelectionView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedProvider: Account.Provider?

    var gitProviders = Account.Provider.allCases

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
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: 400)
    }
}
