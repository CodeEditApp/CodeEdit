//
//  GitCloneView.swift
//  CodeEdit
//
//  Created by Aleksi Puttonen on 23.3.2022.
//

import SwiftUI
import GitClient
import Foundation

struct GitCloneView: View {
    var windowController: NSWindowController
    @State private var repoUrl = ""
    var body: some View {
        HStack(spacing: 8) {
            TextField("Git Repository URL", text: $repoUrl)
                .lineLimit(1)
                .foregroundColor(.black)
            Button("Clone") {
                do {
                    let fileUrl = URL(string: "~/")
                    try GitClient.default(directoryURL: fileUrl!).cloneRepository(repoUrl)
                } catch let error {
                    print(error)
                }
            }
            Button("Cancel") {
                windowController.window?.close()
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
