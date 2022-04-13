//
//  PreferenceAccountsView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

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
        PreferencesContent {
            HStack(alignment: .top) {
                accountSelectionView
                Divider().padding([.leading, .trailing], -10)
                if prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty {
                    emptyView
                } else if
                    !prefs.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty && accountSelection == nil {
                    selectAccount
                } else {
                    accountTypeView
                }
            }
            .background(Rectangle().foregroundColor(Color(NSColor.controlBackgroundColor)))
            .frame(height: 468)
        }
    }

    private var accountSelectionView: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Source Control Accounts")
                .font(.system(size: 12))
                .foregroundColor(Color.secondary)
                .padding([.leading, .top], 10)
                .padding(.bottom, 5)

            Divider().padding([.trailing, .leading], 10)

            List($prefs.preferences.accounts.sourceControlAccounts.gitAccount,
                 selection: $accountSelection) { gitAccount in
                GitAccountItem(sourceControlAccount: gitAccount)
            }.listRowBackground(Color(NSColor.controlBackgroundColor))

            toolbar {
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
        .frame(width: 615)
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
        .frame(maxWidth: 615, maxHeight: .infinity)
    }

    private var selectAccount: some View {
        VStack {
            Text("Select an account from the list in the left panel")
        }
        .frame(maxWidth: 615, maxHeight: .infinity)
    }

    private func toolbar<T: View>(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
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
