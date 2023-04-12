//
//  AccountsSettingsSigninView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/5/23.
//

import SwiftUI

struct AccountsSettingsSigninView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var createToken

    var provider: SourceControlAccount.Provider
    @Binding var addAccountSheetPresented: Bool

    init(_ provider: SourceControlAccount.Provider, addAccountSheetPresented: Binding<Bool>) {
        self.provider = provider
        self._addAccountSheetPresented = addAccountSheetPresented
    }

    @State var server = ""
    @State var username = ""
    @State var personalAccessToken = ""

    @AppSettings var settings

    private let keychain = CodeEditKeychain()

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    content: {
                        if provider.baseURL == nil {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Server")
                                    .font(.caption3)
                                    .foregroundColor(.secondary)
                                TextField("", text: $server, prompt: Text("https://git.example.com"))
                                    .labelsHidden()
                            }
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Username")
                                .font(.caption3)
                                .foregroundColor(.secondary)
                            TextField("", text: $username)
                                .labelsHidden()
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Personal Access Token")
                                .font(.caption3)
                                .foregroundColor(.secondary)
                            SecureField("", text: $personalAccessToken)
                                .labelsHidden()
                         }
                    },
                    header: {
                        VStack(alignment: .center, spacing: 10) {
                            Image(provider.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(12)
                                .frame(width: 52, height: 52)
                                .padding(.top, 5)
                            Text("Sign in to \(provider.name)")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    },
                    footer: {
                        VStack(alignment: .leading, spacing: 5) {
                            if provider == .github {
                                Text("\(provider.name) personal access tokens must have these scopes set:")
                                    .font(.system(size: 10.5))
                                    .foregroundColor(.secondary)
                                HStack(alignment: .center) {
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 2.5) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10.5, weight: .semibold))
                                            Text("admin:public _key")
                                                .font(.system(size: 10.5))
                                        }
                                        HStack(spacing: 2.5) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10.5, weight: .semibold))
                                            Text("write:discussion")
                                                .font(.system(size: 10.5))
                                        }
                                        HStack(spacing: 2.5) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10.5, weight: .semibold))
                                            Text("repo")
                                                .font(.system(size: 10.5))
                                        }
                                        HStack(spacing: 2.5) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10.5, weight: .semibold))
                                            Text("user")
                                                .font(.system(size: 10.5))
                                        }
                                    }
                                    Spacer()
                                }
                                .foregroundColor(.secondary)
                            }
                            Button {
                                createToken(provider.authHelpURL)
                            } label: {
                                if provider.authType == .password {
                                    Text("Create a Password on \(provider.name)")
                                        .font(.system(size: 10.5))
                                } else {
                                    Text("Create a Token on \(provider.name)")
                                        .font(.system(size: 10.5))
                                }
                            }
                            .buttonStyle(.link)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                    }
                )
            }
            .formStyle(.grouped)
            HStack {
                Button {
                    addAccountSheetPresented.toggle()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .frame(maxWidth: .infinity)

                Button {
                    signin()
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                .disabled(username.isEmpty || personalAccessToken.isEmpty)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 300)
    }

    private func signin() {
        let configURL = provider.baseURL == nil ? server : nil

        switch provider {
        case .github, .githubEnterprise:
            let config = GitHubTokenConfiguration(personalAccessToken, url: configURL)
            GitHubAccount(config).me { response in
                switch response {
                case .success:
                    handleGitRequestSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        case .gitlab, .gitlabSelfHosted:
            let config = GitLabTokenConfiguration(personalAccessToken, url: configURL)
            GitLabAccount(config).me { response in
                switch response {
                case .success:
                    handleGitRequestSuccess()
                case .failure(let error):
                    print(error)
                }
            }
        default:
            print("do nothing")
        }
    }

    private func handleGitRequestSuccess() {
        let gitAccounts = settings.accounts.sourceControlAccounts.gitAccounts
        let providerLink = provider.baseURL?.absoluteString ?? server

        if gitAccounts.contains(
            where: {
                $0.serverURL == providerLink &&
                $0.name.lowercased() == username.lowercased()
            }
        ) {
            print("Account with the same username and provider already exists!")
        } else {
            settings.accounts.sourceControlAccounts.gitAccounts.append(
                SourceControlAccount(
                    id: "\(server)_\(username.lowercased())",
                    name: username,
                    description: provider.name,
                    provider: provider,
                    serverURL: server,
                    urlProtocol: true,
                    sshKey: "",
                    isTokenValid: true
                )
            )
            keychain.set(personalAccessToken, forKey: "github_\(username)_enterprise")
            dismiss()
        }
    }
}
