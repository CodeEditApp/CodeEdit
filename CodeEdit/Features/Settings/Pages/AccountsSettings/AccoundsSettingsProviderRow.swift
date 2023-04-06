//
//  AccoundsSettingsAccountRow.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/5/23.
//

import SwiftUI

struct AccoundsSettingsProviderRow: View {
    var name: String
    var iconName: String

    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(6)
                .frame(width: 28, height: 28)
            Text(name)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .overlay(Color(.black).opacity(0.0001))
    }
}
