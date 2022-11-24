//
//  AccountListItem.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import CodeEditSymbols

struct AccountListItem: View {
    var gitClientName: String

    var body: some View {
        HStack {
            Image(symbol: "vault.fill")
                .resizable()
                .frame(width: 28.0, height: 28.0)
            Text(gitClientName)
                .font(.system(size: 12))
        }
    }
}
