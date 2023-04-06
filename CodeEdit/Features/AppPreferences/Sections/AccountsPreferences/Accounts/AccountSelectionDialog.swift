//
//  AccountSelectionDialog.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct AccountSelectionPreferencesDialog: View {
    var gitProviders = [
        SourceControlProvider(name: "Bitbucket Cloud", id: "bitbucketCloud"),
        SourceControlProvider(name: "Bitbucket Server", id: "bitbucketServer"),
        SourceControlProvider(name: "GitHub", id: "github"),
        SourceControlProvider(name: "GitHub Enterprise", id: "githubEnterprise"),
        SourceControlProvider(name: "GitLab", id: "gitlab"),
        SourceControlProvider(name: "GitLab Self-Hosted", id: "gitlabSelfHosted")
    ]

    @State
    var providerSelection: SourceControlProvider.ID? = "github"

    @State
    var openGitLogin = false

    @Binding
    var openAccountDialog: Bool

    var body: some View {
        VStack {
            Text("Select the type of account you would like to add:")
                .font(.system(size: 12))

            List(gitProviders, selection: $providerSelection) {
                AccountListItemView(gitClientName: $0.name)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))

            HStack {
                Button("Cancel") {
                    openAccountDialog.toggle()
                }
                Button("Continue") {
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
            GitHubLoginView(dismissDialog: $openGitLogin, dismissParentDialog: $openAccountDialog)
        case "githubEnterprise":
            GitHubEnterpriseLoginView(dismissDialog: $openGitLogin, dismissParentDialog: $openAccountDialog)
        case "gitlab":
            GitLabLoginView(dismissDialog: $openGitLogin, dismissParentDialog: $openAccountDialog)
        case "gitlabSelfHosted":
            GitLabHostedLoginView(dismissDialog: $openGitLogin, dismissParentDialog: $openAccountDialog)
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
        .frame(width: 300, height: 120)
    }

}
