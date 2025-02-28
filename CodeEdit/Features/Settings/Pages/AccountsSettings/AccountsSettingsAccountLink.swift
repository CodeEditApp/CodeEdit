//
//  AccountsSettingsAccountLink.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/30/23.
//

import SwiftUI

struct AccountsSettingsAccountLink: View {
    @Binding var account: SourceControlAccount

    init(_ account: Binding<SourceControlAccount>) {
        _account = account
    }

    var body: some View {
        NavigationLink(destination: AccountsSettingsDetailsView($account)) {
            Label {
                Text(account.description)
                Text(account.name)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } icon: {
                FeatureIcon(image: Image(account.provider.iconName), size: 26)
                    .padding(.vertical, 2)
                    .padding(.leading, 2)
            }
        }
    }
}
