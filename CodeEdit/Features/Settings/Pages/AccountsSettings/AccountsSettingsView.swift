//
//  AccountSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/4/23.
//

import SwiftUI

struct AccountsSettingsView: View {
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Form {
            Section {
//                ForEach() { account in
//
//                }
//                ForEach(
//                    $prefs.preferences.accounts.sourceControlAccounts.gitAccount
//                ) { gitAccount in
//                    GitAccountItemView(sourceControlAccount: gitAccount)
//                }
//                NavigationLink(destination: .id("test"), label: "Test")
                NavigationLink(
                    destination: {
                        SettingsDetailsView(title: "Test Account 1") {
                            Text("Test Account 1 Details View")
                        }
                    }, label: {
                        VStack(alignment: .leading) {
                            Text("Test Account 1")
                            Text("Test Account 1 Description")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                )
                NavigationLink(
                    destination: {
                        SettingsDetailsView(title: "Test Account 2") {
                            Text("Test Account 2 Details View")
                        }
                    }, label: {
                        VStack(alignment: .leading) {
                            Text("Test Account 2")
                            Text("Test Account 2 Description")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                )
                NavigationLink(
                    destination: {
                        SettingsDetailsView(title: "Test Account 3") {
                            Text("Test Account 3 Details View")
                        }
                    }, label: {
                        VStack(alignment: .leading) {
                            Text("Test Account 3")
                            Text("Test Account 3 Description")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                )
            }
        }
        .formStyle(.grouped)
    }
}
