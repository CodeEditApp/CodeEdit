//
//  GithubLoginView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct GithubLoginView: View {

    @State var accountName: String
    @State var accountToken: String

    var body: some View {
        VStack {
            Text("Sign in to your GitHub account")
                .fontWeight(.bold)
                .font(.system(size: 16))

            VStack(alignment: .trailing) {
                HStack {
                    Text("Account:")
                        .fontWeight(.medium)
                    TextField("Text", text: $accountName)
                        .frame(width: 350)
                }
                HStack {
                    Text("Token:")
                        .fontWeight(.medium)
                    TextField("Enter your Personal Access Token",
                              text: $accountToken)
                        .frame(width: 350)
                }
            }

            VStack {
                Text("GitHub personal access tokens must have these scopes set:")
                    .fontWeight(.bold)

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("admin:public _key")
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("write:discussion")
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("repo")
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("user")
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
                    Button("Create a Token on GitHub") {}
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Cancel") {}
                    Button("Sign In") {}
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color.blue))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 10)
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(width: 485, height: 280)
    }
}

struct GithubLoginView_Previews: PreviewProvider {
    static var previews: some View {
        GithubLoginView(accountName: "nanashili", accountToken: "")
    }
}
