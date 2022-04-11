//
//  AccountSelectionView.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import SwiftUI

struct AccountSelectionView: View {

    @State private var openAccountDialog = false

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            Text("Source Control Accounts")
                .font(.system(size: 12))
                .foregroundColor(Color.secondary)
                .padding([.leading, .top], 10)
                .padding(.bottom, 5)

            Divider().padding([.trailing, .leading], 10)

            List {
                GitAccountItem(gitClientName: "Bitbucket Cloud", gitClientLink: "https://bitbucket.org")
                GitAccountItem(gitClientName: "GitHub", gitClientLink: "https://github.com")
                GitAccountItem(gitClientName: "GitLab", gitClientLink: "https://gitlab.com")
            }.listRowBackground(Color(NSColor.controlBackgroundColor))

            toolbar {
                sidebarBottomToolbar
            }.frame(height: 27)
        }
        .frame(width: 210)
    }

    private var sidebarBottomToolbar: some View {
        HStack {
            Button { openAccountDialog = true } label: {
                Image(systemName: "plus")
            }
            .sheet(isPresented: $openAccountDialog, content: {
                AccountSelectionDialog(dismissDialog: $openAccountDialog)
            })
            .help("Add a Git Account")
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "minus")
            }
            .disabled(true)
            .help("Delete selected Git Account")
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private func toolbar<T: View>(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

struct AccountSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSelectionView()
    }
}
