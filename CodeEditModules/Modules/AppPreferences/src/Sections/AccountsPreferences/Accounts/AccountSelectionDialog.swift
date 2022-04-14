//
//  AccountSelectionDialog.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct AccountSelectionDialog: View {

    var gitProviders = [
        Providers(name: "Bitbucket Cloud", id: "bitbucketCloud"),
        Providers(name: "Bitbucket Server", id: "bitbucketServer"),
        Providers(name: "GitHub", id: "github"),
        Providers(name: "GitHub Enterprise", id: "githubEnterprise"),
        Providers(name: "GitLab", id: "gitlab"),
        Providers(name: "GitLab Self-Hosted", id: "gitlabSelfHosted")
    ]

    @State var providerSelection: Providers.ID? = "github"
    @State var openGitLogin = false

    @Binding var dismissDialog: Bool

    var body: some View {
        VStack {
            Text("Select the type of account you would like to add:")
                .font(.system(size: 12))

            List(gitProviders, selection: $providerSelection) {
                AccountListItem(gitClientName: $0.name)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))

            HStack {
                Button("Cancel") {
                    dismissDialog.toggle()
                }
                Button("Continue") {
                    dismissDialog.toggle()
                    openGitLogin.toggle()
                }
                .sheet(isPresented: $openGitLogin, content: {
                    openAccountLoginDialog
                })
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400, height: 285)
    }

    @ViewBuilder
    private var openAccountLoginDialog: some View {
        switch providerSelection {
        case "bitbucketCloud":
            implementationNeeded
        case "bitbucketServer":
            implementationNeeded
        case "github":
            GithubLoginView(dismissDialog: $openGitLogin)
        case "githubEnterprise":
            GithubEnterpriseLoginView(dismissDialog: $openGitLogin)
        case "gitlab":
            implementationNeeded
        case "gitlabSelfHosted":
            implementationNeeded
        default:
            implementationNeeded
        }
    }

    private var implementationNeeded: some View {
        VStack {
            Text("This git client is currently not supported yet!")
                .font(.system(size: 12))
            HStack {
                Button("Close") {
                    openGitLogin.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
        }
        .padding(20)
        .frame(width: 400, height: 285)
    }

}
