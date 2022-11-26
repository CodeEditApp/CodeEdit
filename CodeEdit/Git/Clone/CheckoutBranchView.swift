//
//  CheckoutBranchView.swift
//  CodeEditModules/Git
//
//  Created by Aleksi Puttonen on 14.4.2022.
//

import Foundation
import SwiftUI

struct CheckoutBranchView: View {
    let shellClient: ShellClient
    @Binding var isPresented: Bool
    @Binding var repoPath: String
    // TODO: This has to be derived from git
    @State var selectedBranch = "main"
    init(isPresented: Binding<Bool>,
         repoPath: Binding<String>,
         shellClient: ShellClient
    ) {
        self.shellClient = shellClient
        self._isPresented = isPresented
        self._repoPath = repoPath
    }
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.bottom, 50)
                VStack(alignment: .leading) {
                    Text("Checkout branch")
                        .bold()
                        .padding(.bottom, 2)
                    Text("Select a branch to checkout")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .alignmentGuide(.trailing) { context in
                        context[.trailing]
                    }
                    Menu {
                        ForEach(getBranches().filter { !$0.contains("HEAD") }, id: \.self) { branch in
                            Button {
                                    guard selectedBranch != branch else { return }
                                    selectedBranch = branch
                            } label: {
                                Text(branch)
                            }.disabled(selectedBranch == branch)
                        }
                    } label: {
                        Text(selectedBranch)
                    }
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        Button("Checkout") {
                            checkoutBranch()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                    .alignmentGuide(.trailing) { context in
                        context[.trailing]
                    }
                    .offset(x: 145)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .frame(width: 400)
        }
    }
}
