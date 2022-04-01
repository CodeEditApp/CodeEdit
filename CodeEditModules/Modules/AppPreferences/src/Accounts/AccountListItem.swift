//
//  AccountListItem.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct AccountListItem: View {

    var gitClientName: String

    var body: some View {
        HStack {
            Image(systemName: "xmark.square.fill")
                .resizable()
                .frame(width: 28.0, height: 28.0)
            Text(gitClientName)
                .font(.system(size: 14))
        }
    }
}
