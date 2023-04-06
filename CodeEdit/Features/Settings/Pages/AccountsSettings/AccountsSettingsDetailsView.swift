//
//  AccountsSettingsDetailView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

struct AccountsSettingsDetailsView: View {
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @Binding var account: Account

    @State var cloneUsing: Bool = false

    init(_ account: Binding<Account>) {
        _account = account
    }

    var body: some View {
        SettingsDetailsView(title: account.description) {
            Form {
                Section {
                    LabeledContent("Account") {
                        Text(account.name)
                    }
                    TextField("Description", text: $account.description)
                    if account.provider.baseURL == nil {
                        TextField("Server", text: $account.serverURL)
                    }
                }

                Section {
                    Picker(selection: $cloneUsing) {
                        Text("HTTPS")
                            .tag(false) // temporary
                        Text("SSH")
                            .tag(true) // temporary
                    } label: {
                        Text("Clone Using")
                        Text("New repositories will be cloned from \(account.provider.name)"
                                 + " using \(cloneUsing ? "SSH" : "HTTPS").")
                    }
                    .pickerStyle(.radioGroup)

                    Picker("SSH Key", selection: $prefs.preferences.accounts.sourceControlAccounts.sshKey) {
                        Text("None")
                        Text("Create New...")
                        Text("Choose...")
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}
