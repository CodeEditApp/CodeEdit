//
//  PreferenceAccountsView.swift
//  
//
//  Created by Tihan-Nico Paxton on 2022/04/01.
//

import SwiftUI

public struct PreferenceAccountsView: View {

    @State private var showDialog = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Source Control Accounts")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    Divider()

                    List {
                        GitAccountItem(gitClientName: "Bitbucket Cloud", gitClientLink: "https://bitbucket.org")
                        GitAccountItem(gitClientName: "GitHub", gitClientLink: "https://github.com")
                        GitAccountItem(gitClientName: "GitLab", gitClientLink: "https://gitlab.com")
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Image(systemName: "minus")
                        Image(systemName: "ellipsis.circle")
                    }
                    .frame(height: 32, alignment: .leading)

                }
                .frame(width: 250)
                .padding(.trailing, 10)

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "xmark.square.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("Bitbucket Cloud")
                            .fontWeight(.medium)
                            .font(.system(size: 16))
                    }

                    Divider()

                    VStack(alignment: .trailing) {
                        HStack {
                            Text("Account:")

                            Text("nanashili")
                                .fontWeight(.bold)
                                .frame(width: 460, alignment: .leading)
                        }

                        HStack {
                            Text("Description:")

                            Text("Bitbucket Cloud")
                                .fontWeight(.bold)
                                .frame(width: 460, alignment: .leading)
                        }.padding(.top, 2)

                        Divider().padding(.top, 15)

                        HStack(alignment: .top) {
                            Text("Clone Using:")

                            VStack(alignment: .leading) {
                                Toggle("HTTPS", isOn: $showDialog)
                                    .toggleStyle(.checkbox)

                                Toggle("SSH", isOn: $showDialog)
                                    .toggleStyle(.checkbox)

                                Text("New repositories will be cloned from Bitbucket Cloud using HTTPS.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.secondary)
                                    .frame(width: 460, alignment: .leading)

                            }.frame(width: 460)
                        }.padding(.top, 10)
                    }.frame(maxWidth: .infinity)
                }
                .frame(width: 564)
            }.frame(maxWidth: .infinity)
        }
        .frame(width: 844, height: 350)
        .padding(20)
    }
}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView()
    }
}
