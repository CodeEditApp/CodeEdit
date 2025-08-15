//
//  LanguageServerInstallView.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/14/25.
//

import SwiftUI

struct LanguageServerInstallView: View {
    @Environment(\.dismiss)
    var dismiss
    @EnvironmentObject private var registryManager: RegistryManager

    @ObservedObject var operation: PackageManagerInstallOperation

    var body: some View {
        VStack(spacing: 0) {
            formContent
            Divider()
            footer
        }
        .constrainHeightToWindow()
        .alert(
            "Confirm Step",
            isPresented: Binding(get: { operation.waitingForConfirmation != nil }, set: { _ in }),
            presenting: operation.waitingForConfirmation
        ) { _ in
            Button("Cancel") {
                registryManager.cancelInstallation()
            }
            Button("Continue") {
                operation.confirmCurrentStep()
            }
        } message: { confirmationMessage in
            Text(confirmationMessage)
        }
    }

    @ViewBuilder private var formContent: some View {
        Form {
            packageInfoSection
            if let error = operation.error {
                Section {
                    HStack(spacing: 0) {
                        Image(systemName: "exclamationmark.octagon.fill").foregroundColor(.red)
                        Text("Error Occurred")
                    }
                    .font(.title3)
                    ErrorDescriptionLabel(error: error)
                }
            }
            progressSection
            outputSection
        }
        .formStyle(.grouped)
    }

    @ViewBuilder private var footer: some View {
        HStack {
            Spacer()
            if operation.currentStep != nil {
                Button {
                    registryManager.cancelInstallation()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 56)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .frame(minWidth: 56)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    @ViewBuilder private var packageInfoSection: some View {
        Section {
            LabeledContent("Installing Package", value: operation.package.sanitizedName)
            LabeledContent("Source") {
                sourceButton
            }
            Text(operation.package.sanitizedDescription)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .labelsHidden()
        }
    }

    @ViewBuilder private var sourceButton: some View {
        if #available(macOS 14.0, *) {
            Button(operation.package.homepagePretty) {
                guard let homepage = operation.package.homepageURL else { return }
                NSWorkspace.shared.open(homepage)
            }
            .buttonStyle(.plain)
            .foregroundColor(Color(NSColor.linkColor))
            .focusEffectDisabled()
        } else {
            Button(operation.package.homepagePretty) {
                guard let homepage = operation.package.homepageURL else { return }
                NSWorkspace.shared.open(homepage)
            }
            .buttonStyle(.plain)
            .foregroundColor(Color(NSColor.linkColor))
        }
    }

    @ViewBuilder private var progressSection: some View {
        Section {
            LabeledContent("Step", value: operation.currentStep?.name ?? "Finished")
            ProgressView(operation.progress)
                .progressViewStyle(.linear)
        }
    }

    @ViewBuilder private var outputSection: some View {
        Section {
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
            .frame(height: 350)
        }
    }
}
