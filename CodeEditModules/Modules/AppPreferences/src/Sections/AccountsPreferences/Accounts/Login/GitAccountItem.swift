//
//  GitAccountItem.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import CodeEditSymbols

struct GitAccountItem: View {

    @Binding
    var sourceControlAccount: SourceControlAccounts

    var body: some View {
        HStack {
            Image(symbol: "vault.fill")
                .resizable()
                .frame(width: 24.0, height: 24.0)

            VStack(alignment: .leading) {
                Text(sourceControlAccount.gitProvider)
                    .font(.system(size: 12))
                Text(sourceControlAccount.gitProviderLink)
                    .font(.system(size: 10))
            }
        }
    }
}
