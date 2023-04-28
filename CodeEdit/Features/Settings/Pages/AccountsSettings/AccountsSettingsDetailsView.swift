//
//  AccountsSettingsDetailView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

struct AccountsSettingsDetailsView: View {
    @AppSettings var settings

    @Binding var account: SourceControlAccount

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var cloneUsing: Bool = false
    @State var deleteConfirmationIsPresented: Bool = false

    init(_ account: Binding<SourceControlAccount>) {
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

                    Picker("SSH Key", selection: $settings.accounts.sourceControlAccounts.sshKey) {
                        Text("None")
                        Text("Create New...")
                        Text("Choose...")
                    }
                } footer: {
                    HStack {
                        Button("Delete Account...") {
                            deleteConfirmationIsPresented.toggle()
                        }
                        .alert(
                            Text("Are you sure you want to delete the account “\(account.description)”?"),
                            isPresented: $deleteConfirmationIsPresented
                        ) {
                            Button("OK") {
                                // Handle the account delete
                                handleAccountDelete()
                            }
                            Button("Cancel") {
                                // Handle the cancel, dismiss the alert
                                deleteConfirmationIsPresented.toggle()
                            }
                        } message: {
                            Text("Deleting this account will remove it from CodeEdit.")
                        }

                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        }
    }

    private func handleAccountDelete() {
        let gitAccounts = settings.accounts.sourceControlAccounts.gitAccounts
        // Delete account by finding the position of the account and remove by position
        // We can abort if it is `nil` because account should exist
        settings.accounts.sourceControlAccounts.gitAccounts.remove(at: gitAccounts.firstIndex(of: account)!)
        self.presentationMode.wrappedValue.dismiss()
    }
}
