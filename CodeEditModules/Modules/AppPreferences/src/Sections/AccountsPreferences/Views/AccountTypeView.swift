//
//  AccountTypeView.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

struct AccountTypeView: View {

    @State
    var useHTTP: Bool

    @State
    var useSSH: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Bitbucket Cloud")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .padding(.top, 10)
                .padding(.bottom, 5)

            Divider()

            PreferencesSection("Account") {
                Text("nanashili")
                    .fontWeight(.medium)
            }.padding(.top, 10)

            PreferencesSection("Description") {
                Text("Bitbucket Cloud")
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
        }
        .padding(.trailing, 20)
        .frame(width: 615)
    }
}

struct AccountTypeView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTypeView(useHTTP: true, useSSH: false)
    }
}
