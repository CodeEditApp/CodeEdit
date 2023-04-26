//
//  AccountSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/4/23.
//

import SwiftUI

struct AccountsSettingsView: View {
    @AppSettings var settings

    @State private var addAccountSheetPresented: Bool = false
    @State private var selectedProvider: SourceControlAccount.Provider?

    var body: some View {
        SettingsForm {
            Section {
                if $settings.accounts.sourceControlAccounts.gitAccounts.isEmpty {
                    Text("No accounts")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach($settings.accounts.sourceControlAccounts.gitAccounts) { $account in
                        AccountsSettingsAccountLink($account)
                    }
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
                Button("Close") {
                    addAccountSheetPresented.toggle()
                    selectedProvider = nil

                }
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
    }
}

struct AccountsSettingsAccountLink: View {
    @Binding var account: SourceControlAccount

    init(_ account: Binding<SourceControlAccount>) {
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
