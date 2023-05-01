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
                Image(account.provider.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(6)
                    .frame(width: 26, height: 26)
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                    .padding(.leading, 2)
            }
        }
    }
}
