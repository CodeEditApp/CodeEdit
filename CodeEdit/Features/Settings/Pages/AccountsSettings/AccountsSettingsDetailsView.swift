//
//  AccountsSettingsDetailView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

struct AccountsSettingsDetailsView: View {
    @ObservedObject
    private var prefs: Settings = .shared

    @Binding var account: Account

    @State var cloneUsing: Bool = false
    @State var deleteConfirmationIsPresented: Bool = false

    init(_ account: Binding<Account>) {
        _account = account
    }

    var body: some View {
        SettingsDetailsView(title: account.description) {
            SettingsForm {
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
                } footer: {
                    HStack {
                        Button("Delete Account...") {
                            deleteConfirmationIsPresented.toggle()
                        }
                        .alert(isPresented: $deleteConfirmationIsPresented) {
                            Alert(
                                title: Text("Are you sure you want to delete the account “\(account.description)”?"),
                                message: Text("Deleting this account will remove it from CodeEdit."),
                                primaryButton: .default(Text("OK")),
                                secondaryButton: .default(Text("Cancel"))
                            )
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}
