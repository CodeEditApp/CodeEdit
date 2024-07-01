//
//  GitCloneView.swift
//  CodeEditModules/Git
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import Foundation
import Combine

struct GitCloneView: View {
    @Environment(\.dismiss)
    private var dismiss

    @StateObject private var viewModel: GitCloneViewModel = .init()

    private let openBranchView: (URL) -> Void
    private let openDocument: (URL) -> Void

    init(
        openBranchView: @escaping (URL) -> Void,
        openDocument: @escaping (URL) -> Void
    ) {
        self.openBranchView = openBranchView
        self.openDocument = openDocument
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.bottom, 50)
                VStack(alignment: .leading) {
                    Text("Clone a repository")
                        .bold()
                        .padding(.bottom, 2)
                    Text("Enter a git repository URL:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .alignmentGuide(.trailing) { context in
                            context[.trailing]
                        }
                    TextField("Git Repository URL", text: $viewModel.repoUrlStr)
                        .lineLimit(1)
                        .padding(.bottom, 15)
                        .frame(width: 300)

                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        Button("Clone") {
                            cloneRepository()
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(!viewModel.isValidUrl(url: viewModel.repoUrlStr))
                    }
                    .offset(x: 185)
                    .alignmentGuide(.leading) { context in
                        context[.leading]
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .onAppear {
                viewModel.checkClipboard()
            }
            .sheet(isPresented: $viewModel.isCloning) {
                NavigationStack {
                    VStack {
                        ProgressView(
                            viewModel.cloningProgress.state.label,
                            value: viewModel.cloningProgress.progress,
                            total: 100
                        )
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button("Cancel Cloning") {
                            viewModel.cloningTask?.cancel()
                            viewModel.cloningTask = nil
                            viewModel.isCloning = false
                        }
                    }
                }
                .padding()
                .frame(width: 350)
            }
        }
    }

    func cloneRepository() {
        viewModel.cloneRepository { localPath in
            dismiss()

            guard let gitClient = viewModel.gitClient else { return }

            Task {
                let branches = ((try? await  gitClient.getBranches()) ?? [])
                    .filter({ $0.isRemote })
                if branches.count > 1 {
                    openBranchView(localPath)
                    return
                }

                openDocument(localPath)
            }
        }
    }
}
