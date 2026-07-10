//
//  GitCloneView.swift
//  CodeEditModules/Git
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import CodeEditCore
import SwiftUI
import Foundation
import Combine
import ShellClient

struct GitCloneView: View {
    @Environment(\.dismiss)
    private var dismiss

    @StateObject private var viewModel: GitCloneViewModel

    private let openBranchView: (URL) -> Void
    private let openDocument: (URL) -> Void

    init(
        shellClient: ShellClientProtocol,
        openBranchView: @escaping (URL) -> Void,
        openDocument: @escaping (URL) -> Void
    ) {
        _viewModel = .init(wrappedValue: GitCloneViewModel(shellClient: shellClient))
        self.openBranchView = openBranchView
        self.openDocument = openDocument
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading) {
                    Text("Clone a Repository")
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

                    HStack {
                        Spacer()
                        Button("Cancel") {
                            dismiss()
                        }
                        Button("Clone") {
                            cloneRepository()
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(!viewModel.isValidUrl(url: viewModel.repoUrlStr))
                    }
                }
                .frame(width: 300)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .onAppear {
                viewModel.checkClipboard()
            }
            .sheet(isPresented: $viewModel.isCloning) {
                cloningSheet
            }
        }
    }

    @ViewBuilder private var cloningSheet: some View {
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

    func cloneRepository() {
        viewModel.cloneRepository { localPath in
            dismiss()

            let gitClient = GitClient(directoryURL: localPath, shellClient: viewModel.shellClient)

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
