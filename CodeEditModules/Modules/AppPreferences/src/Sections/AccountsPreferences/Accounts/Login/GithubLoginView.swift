//
//  GithubLoginView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import Accounts

struct GithubLoginView: View {

    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    @Binding var dismissDialog: Bool
    @Binding var selectedGitProvider: Providers.ID?

    var body: some View {
        VStack {
            Text("Sign in to your GitHub account")

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

            VStack {
                Text("GitHub personal access tokens must have these scopes set:")
                    .fontWeight(.bold)
                    .font(.system(size: 11))

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("admin:public _key")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("write:discussion")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("repo")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("user")
                            .font(.system(size: 10))
                    }
                }.padding(.top, 2)
            }
            .background(Rectangle().foregroundColor(Color("Logins")))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .background(RoundedRectangle(cornerRadius: 4)
                .stroke(Color("Stroke"), lineWidth: 1))

            HStack {
                HStack {
                    Button("Create a Token on GitHub") {
                        createToken(URL(string: "https://github.com/settings/tokens/new")!)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Cancel") {
                        dismissDialog = false
                    }
                    if accountToken.isEmpty {
                        Button("Sign In") {
                            authenticateGithubAccount(selectedGitProvider!, githubToken: accountToken)
                        }
                        .disabled(true)
                    } else {
                        Button("Sign In") {
                            authenticateGithubAccount(selectedGitProvider!, githubToken: accountToken)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 10)
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(width: 485, height: 280)
    }
}
