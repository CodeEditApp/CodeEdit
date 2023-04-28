//
//  AccountsSettingsDetailView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/6/23.
//

import SwiftUI

struct AccountsSettingsDetailsView: View {
    @AppSettings var settings

    @Binding var account: SourceControlAccount

    @State var cloneUsing: Bool = false
    @State var deleteConfirmationIsPresented: Bool = false

    init(_ account: Binding<SourceControlAccount>) {
        _account = account
    }

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base URL of settings.
    ///
    /// Points to `~/Library/Application Support/CodeEdit/`
    internal var sshURL: URL {
        filemanager
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".ssh", isDirectory: true)
    }

    func isSSHKey(_ contents: String) -> Bool {
        if contents.starts(with: "-----BEGIN OPENSSH PRIVATE KEY-----\n") &&
           contents.hasSuffix("\n-----END OPENSSH PRIVATE KEY-----\n") {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        SettingsDetailsView(title: account.description) {
            SettingsForm {
                Section {
                    LabeledContent("Account") {
                        Text(account.name)
                    }
                    TextField("Description", text: $account.description)
                    if account.provider.baseURL == nil {
                        TextField("Server", text: $account.serverURL)
                    }
                }

                Section {
                    Picker(selection: $cloneUsing) {
                        Text("HTTPS")
                            .tag(false) // temporary
                        Text("SSH")
                            .tag(true) // temporary
                    } label: {
                        Text("Clone Using")
                        Text("New repositories will be cloned from \(account.provider.name)"
                                 + " using \(cloneUsing ? "SSH" : "HTTPS").")
                    }
                    .pickerStyle(.radioGroup)
                    if cloneUsing {
                        Picker("SSH Key", selection: $settings.accounts.sourceControlAccounts.sshKey) {
                            Text("None")
                                .tag("")
                            Divider()
                            if let sshPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
                                ".ssh",
                                isDirectory: true
                            ) as URL? {
                                if let files = try? FileManager.default.contentsOfDirectory(
                                    atPath: sshPath.path
                                ) {
                                    ForEach(files, id: \.self) { filename in
                                        let fileURL = sshPath.appendingPathComponent(filename)
                                        if let contents = try? String(contentsOf: fileURL) {
                                            if isSSHKey(contents) {
                                                Text(filename).tag(contents)
                                            }
                                        }
                                    }
                                    Divider()
                                }
                            }
                            Text("Create New...")
                            Text("Choose...")
                        }
                    }
                } footer: {
                    HStack {
                        Button("Delete Account...") {
                            deleteConfirmationIsPresented.toggle()
                        }
                        .alert(isPresented: $deleteConfirmationIsPresented) {
                            Alert(
                                title: Text("Are you sure you want to delete the account “\(account.description)”?"),
                                message: Text("Deleting this account will remove it from CodeEdit."),
                                primaryButton: .default(Text("OK")),
                                secondaryButton: .default(Text("Cancel"))
                            )
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}
