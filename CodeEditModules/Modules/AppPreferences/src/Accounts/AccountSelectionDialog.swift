//
//  AccountSelectionDialog.swift
//  
//
//  Created by Tihan-Nico Paxton on 2022/04/01.
//

import SwiftUI

struct AccountSelectionDialog: View {

    var gitProviders: [String] = ["Bitbucket Cloud",
                                  "Bitbucket Server",
                                  "GitHub",
                                  "GitHub Enterprise",
                                  "GitLab",
                                  "GitLab Self-Hosted"]

    init() {}

    var body: some View {
        VStack {
            Text("Select the type of account you would like to add:")
                .font(.system(size: 12))

            List {
                ForEach(gitProviders.indices, id: \.self) { providers in
                    AccountListItem(gitClientName: gitProviders[providers])
                }
            }.background(Color(NSColor.controlBackgroundColor))

            HStack {
                Button("Cancel") {}
                Button("Continue") {}
                    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color.blue))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
        }
        .padding(20)
        .frame(width: 400, height: 285)
    }
}

struct AccountSelectionDialog_Previews: PreviewProvider {
    static var previews: some View {
        AccountSelectionDialog()
    }
}
