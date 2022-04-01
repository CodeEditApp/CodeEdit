//
//  SourceControlGitView.swift
//  
//
//  Created by Tihan-Nico Paxton on 2022/04/01.
//

import SwiftUI

struct SourceControlGitView: View {

    @State var authorName: String
    @State var isChecked: Bool

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Author Name:")
                TextField("Text", text: $authorName)
                    .frame(width: 280)
            }

            HStack {
                Text("Author Email:")
                TextField("Text", text: $authorName)
                    .frame(width: 280)
            }

            HStack(alignment: .top) {
                Text("Ignored Files:")
                List {
                    Text("*~")
                    Text(".DS_Store")
                }
                .frame(width: 280, height: 180)
                .background(Color(NSColor.textBackgroundColor))
            }

            HStack(alignment: .top) {
                Text("Options:")
                VStack(alignment: .leading) {
                    Toggle("Prefer to rebase when pulling", isOn: $isChecked)
                        .toggleStyle(.checkbox)
                        .frame(width: 280, alignment: .leading)
                    Toggle("Show merge commits in per-file log", isOn: $isChecked)
                        .toggleStyle(.checkbox)
                        .frame(width: 280, alignment: .leading)
                }
            }.padding(.top, 10)
        }
        .frame(width: 844, height: 350)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SourceControlGitView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGitView(authorName: "Nanashi Li", isChecked: false)
    }
}
