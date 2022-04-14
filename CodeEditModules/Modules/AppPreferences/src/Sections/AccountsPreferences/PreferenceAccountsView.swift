//
//  PreferenceAccountsView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import CodeEditUI

// swiftlint:disable for_where
public struct PreferenceAccountsView: View {

    @State private var useHHTP = false
    @State private var openAccountDialog = false
    @State var useHTTP = true
    @State var useSSH = false
    @State var accountSelection: SourceControlAccounts.ID?

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
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
                 .listRowBackground(Color(NSColor.controlBackgroundColor))

            PreferencesToolbar {
                sidebarBottomToolbar
            }.frame(height: 27)
        }
        .frame(width: 210)
    }

    private var accountTypeView: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(getSourceControlAccount(selectedAccountId: accountSelection ?? "")?.gitProvider ?? "")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.top, 10)
                .padding(.bottom, 5)

            Divider()

            PreferencesSection("Account") {
                Text(getSourceControlAccount(selectedAccountId: accountSelection ?? "")?.gitAccountName ?? "")
                    .fontWeight(.medium)
            }.padding(.top, 10)

            PreferencesSection("Description") {
                Text(getSourceControlAccount(selectedAccountId: accountSelection ?? "")?.gitProviderDescription ?? "")
                    .fontWeight(.medium)
            }.padding(.bottom, 10)

            Divider()

            PreferencesSection("Clone Using") {
                Toggle("HTTPS", isOn: $useHTTP)
                    .toggleStyle(.checkbox)

                Toggle("SSH", isOn: $useSSH)
                    .toggleStyle(.checkbox)

                Text("New repositories will be cloned from Bitbucket Cloud using HTTPS.")
                    .lineLimit(2)
                    .font(.system(size: 9))
                    .foregroundColor(Color.secondary)
            }.padding(.top, 10)

            PreferencesSection("SSH Key") {
                Picker("", selection: $prefs.preferences.accounts.sourceControlAccounts.sshKey) {
                    Text("None")
                    Text("Create New...")
                    Text("Choose...")
                }
            }
        }
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity)
        .background(EffectView(material: .contentBackground))
    }

    private var sidebarBottomToolbar: some View {
        HStack {
            Button { openAccountDialog = true } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $openAccountDialog, content: {
                AccountSelectionDialog(dismissDialog: $openAccountDialog)
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
        .background(EffectView(material: .contentBackground))
    }

    private var selectAccount: some View {
        VStack {
            Text("Select an account from the list in the left panel")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EffectView(material: .contentBackground))
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
    }
}
