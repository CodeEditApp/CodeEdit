//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols
import AppKit

/// A struct for settings
struct SettingsView: View {
    @StateObject var model = SettingsModel()

    /// An array of navigationItem(s)
    private static let pages: [SettingsPage] = [
        .init(.general, baseColor: .gray, icon: .system("gear")),
        .init(.accounts, baseColor: .blue, icon: .system("at")),
        .init(.behavior, baseColor: .orange, icon: .system("flowchart")),
        .init(.navigation, baseColor: .green, icon: .system("arrow.triangle.turn.up.right.diamond")),
        .init(.theme, baseColor: .pink, icon: .system("paintbrush")),
        .init(.textEditing, baseColor: .blue, icon: .system("square.and.pencil")),
        .init(.terminal, baseColor: .blue, icon: .system("terminal")),
        .init(.keybindings, baseColor: .gray, icon: .system("keyboard")),
        .init(.sourceControl, baseColor: .blue, icon: .system("arrow.triangle.pull")),
        .init(.components, baseColor: .blue, icon: .system("puzzlepiece")),
        .init(.location, baseColor: .green, icon: .system("externaldrive")),
        .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
    ]

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage = pages.first!
    @State private var searchText: String = ""

    @Environment(\.presentationMode) var presentationMode

    let updater: SoftwareUpdater

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPage) {
                Section {
                    ForEach(Self.pages) { item in
                        if searchText.isEmpty || item.name.rawValue.lowercased().contains(searchText.lowercased()) {
                            SettingsPageView(item)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(215)
            .safeAreaInset(edge: .top) {
                TextField("Search", text: $searchText, prompt: Text("Search"))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 10)
                    .controlSize(.large)
            }
        } detail: {
            Group {
                switch selectedPage.name {
                case .general:
                    GeneralSettingsView().environmentObject(updater)
                case .accounts:
                    AccountsSettingsView()
                case .theme:
                    ThemeSettingsView()
                case .textEditing:
                    TextEditingSettingsView()
                case .terminal:
                    TerminalSettingsView()
                case .sourceControl:
                    SourceControlSettingsView()
                case .location:
                    LocationsSettingsView()
                default:
                    Text("Implementation Needed").frame(alignment: .center)
                }
            }
            .navigationSplitViewColumnWidth(500)
            .hideSidebarToggle()
            .onAppear {
                model.showingDetails = false
            }
        }
        .navigationTitle(selectedPage.name.rawValue)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                if !model.showingDetails {
                    Rectangle()
                        .fill(presentationMode.wrappedValue.isPresented ? .red : .blue)
                        .frame(width: 10)
                        .opacity(0)
                } else {
                    EmptyView()
                }
            }
        }
        .environmentObject(model)
    }
}

struct SettingsDetailsView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: SettingsModel

    let title: String

    @ViewBuilder
    var content: Content

    var body: some View {
        content
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    print(self.presentationMode.wrappedValue)
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                Text(title)
            }
        }
        .hideSidebarToggle()
        .task {
            let window = NSApp.windows.first { $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window" }!
            window.title = title
        }
        .onAppear {
            model.showingDetails = true
        }
    }
}

class SettingsModel: ObservableObject {
    @Published var showingDetails: Bool = false
}
