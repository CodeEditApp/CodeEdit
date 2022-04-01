//
//  GitAccountItem.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct GitAccountItem: View {

    var gitClientName: String
    var gitClientLink: String

    var body: some View {
        HStack {
            Image(systemName: "xmark.square.fill")
                .resizable()
                .frame(width: 24.0, height: 24.0)

            VStack(alignment: .leading) {
                Text(gitClientName)
                    .font(.system(size: 12))
                Text(gitClientLink)
                    .font(.system(size: 10))
            }
        }
    }
}
