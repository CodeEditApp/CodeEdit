//
//  LanguageServerInstallView.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/14/25.
//

import SwiftUI

struct LanguageServerInstallView: View {
    @ObservedObject var operation: PackageManagerInstallOperation

    var body: some View {
        VStack(alignment: .leading) {
            Text("Installing: " + operation.package.name)
                .font(.title)
            ProgressView(operation.progress)
                .progressViewStyle(.linear)

            if let error = operation.error {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Image(systemName: "exclamationmark.octagon.fill").foregroundColor(.red)
                        Text("Error Occurred")
                    }
                    .font(.title3)
                    ErrorDescriptionLabel(error: error)
                }
                .overlay { RoundedRectangle(cornerRadius: 8).stroke(.separator) }
            }

            VStack {
                ScrollViewReader { proxy in
                    List(operation.accumulatedOutput) { line in
                        HStack(spacing: 0) {
                            Text(line.contents)
                                .font(.caption.monospaced())
                            Spacer(minLength: 0)
                        }
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .onReceive(operation.$accumulatedOutput) { output in
                        proxy.scrollTo(output.last?.id)
                    }
                }
            }
            .frame(height: 250)
            .overlay { RoundedRectangle(cornerRadius: 8).stroke(.separator) }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
