//
//  AccountSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/4/23.
//

import SwiftUI

struct AccountsSettingsView: View {
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State private var accounts: [Account]
    @State private var addAccountSheetPresented: Bool = false
    @State private var selectedProvider: Account.Provider?

    init() {
        self.accounts = [
            Account(name: "austincondiff", description: "GitHub", provider: .github, serverURL: ""),
            Account(name: "austin.condiff@mycompany.com", description: "GitLab", provider: .gitlab, serverURL: ""),
            Account(
                name: "austin.condiff@acme.com",
                description: "BitBucket Server",
                provider: .bitbucketServer,
                serverURL: "https://git.acme.com"
            )
        ]
    }

    var body: some View {
        SettingsForm {
            Section {
                ForEach($accounts) { $account in
                    AccountsSettingsAccountLink($account)
                }
            } footer: {
                HStack {
                    Spacer()
                    Button("Add Account...") { addAccountSheetPresented.toggle() }
                    .sheet(isPresented: $addAccountSheetPresented, content: {
                        AccountSelectionView(selectedProvider: $selectedProvider)
                    })
                    .sheet(item: $selectedProvider, content: { provider in
                        switch provider {
                        case .github, .githubEnterprise, .gitlab, .gitlabSelfHosted:
                            AccountsSettingsSigninView(provider, addAccountSheetPresented: $addAccountSheetPresented)
                        default:
                            implementationNeeded
                        }
                    })
                }
                .padding(.top, 10)
            }
        }
    }

    private var implementationNeeded: some View {
        VStack(spacing: 20) {
            Text("This git client is currently not supported.")
            HStack {
                Button("Close") { selectedProvider = nil }
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
    }
}

struct AccountsSettingsAccountLink: View {
    @Binding var account: Account

    init(_ account: Binding<Account>) {
        _account = account
    }

    var body: some View {
        NavigationLink(destination: AccountsSettingsDetailsView($account)) {
            Label {
                Text(account.provider.name)
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
