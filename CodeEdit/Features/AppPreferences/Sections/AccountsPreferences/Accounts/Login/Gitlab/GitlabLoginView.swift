//
//  GitLabLoginView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/21.
//

import SwiftUI

struct GitLabLoginView: View {

    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    private let keychain = CodeEditKeychain()

    @Binding var dismissDialog: Bool

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack {
            Text("Sign in to your GitLab account")

            VStack(alignment: .trailing) {
                HStack {
                    Text("Account:")
                    TextField("Enter your username", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("Token:")
                    SecureField("Enter your Personal Access Token",
                                text: $accountToken)
                    .frame(width: 300)
                }
            }

            HStack {
                HStack {
                    Button("Create a Token on GitLab") {
                        createToken(URL(string: "https://gitlab.com/-/profile/personal_access_tokens")!)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Cancel") {
                        dismissDialog.toggle()
                    }
                    if accountToken.isEmpty {
                        Button("Sign In") {}
                        .disabled(true)
                    } else {
                        Button("Sign In") {
                            loginGitLab(gitAccountName: accountName)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 10)
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(width: 485, height: 160)
    }

    private func loginGitLab(gitAccountName: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitLabTokenConfiguration(accountToken)
        GitLabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    print("Account with the username already exists!")
                } else {
                    print(user)
                    prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: gitAccountName.lowercased(),
                                              gitProvider: "GitLab",
                                              gitProviderLink: "https://gitlab.com",
                                              gitProviderDescription: "GitLab",
                                              gitAccountName: gitAccountName,
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    keychain.set(accountToken, forKey: "gitlab_\(accountName)")
                    dismissDialog = false
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
