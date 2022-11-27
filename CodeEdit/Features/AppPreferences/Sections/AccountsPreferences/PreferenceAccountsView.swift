//
//  PreferenceAccountsView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

// swiftlint:disable for_where
struct PreferenceAccountsView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var openAccountDialog = false

    @State
    private var cloneUsing = false

    @State
    var accountSelection: SourceControlAccounts.ID?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 1) {
                accountSelectionView
                if prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty {
                    emptyView
                } else if
                    !prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty && accountSelection == nil {
                    selectAccount
                } else {
                    accountTypeView
                }
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(width: 872, height: 468)
            .padding()
        }
    }

    private var accountSelectionView: some View {
        VStack(alignment: .leading, spacing: 1) {
            PreferencesToolbar {
                Text("Source Control Accounts")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            List($prefs.preferences.accounts.sourceControlAccounts.gitAccount,
                 selection: $accountSelection) { gitAccount in
                GitAccountItem(sourceControlAccount: gitAccount)
            }
                 .background(
                    EffectView(.contentBackground)
                 )
            PreferencesToolbar {
                sidebarBottomToolbar
            }
        }
        .frame(width: 210)
    }

    private var accountTypeView: some View {
        VStack(alignment: .leading, spacing: 1) {
            PreferencesToolbar {
                Text(getSourceControlAccount(selectedAccountId: accountSelection ?? "")?.gitProvider ?? "")
                    .fontWeight(.medium)
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack {
                PreferencesSection("Account", width: 100) {
                    Text(getSourceControlAccount(selectedAccountId: accountSelection ?? "")?.gitAccountName ?? "")
                        .fontWeight(.medium)
                }

                PreferencesSection("Description", width: 100) {
                    let account = getSourceControlAccount(selectedAccountId: accountSelection ?? "")
                    Text(account?.gitProviderDescription ?? "")
                        .fontWeight(.medium)
                }

                Divider()
                    .padding(.bottom, 5)

                PreferencesSection("Clone Using", width: 100) {
                    Picker("", selection: $cloneUsing) {
                        Text("HTTPS")
                            .tag(false) // temporary
                        Text("SSH")
                            .tag(true) // temporary
                    }
                    .pickerStyle(.radioGroup)

                    Text("New repositories will be cloned from Bitbucket Cloud using HTTPS.")
                        .lineLimit(2)
                        .font(.system(size: 11))
                        .foregroundColor(Color.secondary)
                }

                PreferencesSection("SSH Key", width: 100) {
                    Picker("", selection: $prefs.preferences.accounts.sourceControlAccounts.sshKey) {
                        Text("None")
                        Text("Create New...")
                        Text("Choose...")
                    }
                }
            }
            .padding(.top, 10)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(EffectView(.contentBackground))
        }
    }

    private var sidebarBottomToolbar: some View {
        HStack {
            Button {
                openAccountDialog.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $openAccountDialog, content: {
                AccountSelectionDialog(openAccountDialog: $openAccountDialog)
            })
            .help("Add a Git Account")
            .buttonStyle(.plain)
            Button {
                removeSourceControlAccount(selectedAccountId: accountSelection ?? "")
            } label: {
                Image(systemName: "minus")
            }
            .disabled(true)
            .help("Delete selected Git Account")
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Text("Click the add (+) button to create a new account")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EffectView(.contentBackground))
    }

    private var selectAccount: some View {
        VStack {
            Text("Select an account from the list in the left panel")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EffectView(.contentBackground))
    }

    private func getSourceControlAccount(selectedAccountId: String) -> SourceControlAccounts? {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount
        return gitAccounts.first { $0.id == selectedAccountId }
    }

    private func removeSourceControlAccount(selectedAccountId: String) {
        var gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        for account in gitAccounts {
            if account.id == selectedAccountId {
                let index = gitAccounts.firstIndex(of: account)
                gitAccounts.remove(at: index ?? 0)
            }
        }
    }

}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView()
            .preferredColorScheme(.dark)
    }
}
