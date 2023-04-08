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
    @Environment(\.colorScheme) private var colorScheme

    /// An array of navigationItem(s)
    private static let pages: [SettingsPage] = [
        .init(.general, baseColor: .gray, icon: .system("gear")),
        .init(.accounts, baseColor: .blue, icon: .system("at")),
        .init(.behavior, baseColor: .red, icon: .system("flowchart.fill")),
        .init(.navigation, baseColor: .green, icon: .system("arrow.triangle.turn.up.right.diamond.fill")),
        .init(.theme, baseColor: .pink, icon: .system("paintbrush.fill")),
        .init(.textEditing, baseColor: .blue, icon: .system("pencil.line")),
        .init(.terminal, baseColor: .blue, icon: .system("terminal.fill")),
        .init(.keybindings, baseColor: .gray, icon: .system("keyboard.fill")),
        .init(.sourceControl, baseColor: .blue, icon: .symbol("vault")),
        .init(.components, baseColor: .blue, icon: .system("puzzlepiece.fill")),
        .init(.location, baseColor: .green, icon: .system("externaldrive.fill")),
        .init(.advanced, baseColor: .gray, icon: .system("gearshape.2.fill"))
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
//            .safeAreaInset(edge: .top) {
//                TextField("Search", text: $searchText, prompt: Text("Search"))
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.horizontal, 10)
//                    .controlSize(.large)
//            }
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
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
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

class SettingsModel: ObservableObject {
    @Published var showingDetails: Bool = false
    @Published var scrolledToTop: Bool = false
}
