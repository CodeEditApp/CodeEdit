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

    @State var providerSelection: Providers.ID?
    @State var openGitLogin = false

    @Binding var dismissDialog: Bool

    var body: some View {
        VStack {
            Text("Select the type of account you would like to add:")
                .font(.system(size: 12))

            List(gitProviders, selection: $providerSelection) {
                AccountListItem(gitClientName: $0.name)
            }.background(Color(NSColor.controlBackgroundColor))

            HStack {
                Button("Cancel") {
                    dismissDialog = false
                }
                Button("Continue") {
                    dismissDialog = false
                    openGitLogin = true
                }
                .sheet(isPresented: $openGitLogin, content: {
                    GithubLoginView(dismissDialog: $openGitLogin, selectedGitProvider: $providerSelection)
                })
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
        }
        .padding(20)
        .frame(width: 400, height: 285)
    }
}
