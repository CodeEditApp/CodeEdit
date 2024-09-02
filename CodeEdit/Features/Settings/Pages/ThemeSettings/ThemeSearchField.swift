//
//  ThemeSearchField.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 30.08.24.
//

import SwiftUI

struct ThemeSearchField: View {
    @Binding var themeSearchQuery: String
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 2)
                    .padding(.trailing, -7)

                TextField("", text: $themeSearchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .overlay {
                        HStack {
                            Text("Search")
                                .foregroundStyle(.secondary)
                                .opacity(themeSearchQuery.isEmpty ? 1 : 0)
                                .padding(.leading, 6.5)

                            Spacer()
                        }
                    }
            }
            .padding(3)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.secondary)
//                    .blendMode(.overlay)
                    .blendMode(.difference)
                    .opacity(0.1)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.2)
            }
//            TextField(text: $themeSearchQuery, prompt: Text("Search")) {
//                Label("Test", systemImage: "magnifyingglass")
//            }
//            .textFieldStyle(.roundedBorder)
//            .padding()
        }
    }
}

#Preview {
    ThemeSearchField(themeSearchQuery: .constant("Test"))
}
