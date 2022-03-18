//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import WorkspaceClient
import CodeEditorView

struct WorkspaceView: View {
    @State private var directoryURL: URL?
    @State private var workspaceClient: WorkspaceClient?
    // TODO: Create a ViewModel to hold selectedId, openFileItems,
    // ... to pass it to subviews as an EnvironmentObject (less boilerplate parameters)
    @State private var selectedId: WorkspaceClient.FileId?
    @State private var openFileItems: [WorkspaceClient.FileItem] = []
    @State private var urlInit = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""

    var tabBarHeight = 28.0
    private var path: String = ""

    func closeFileTab(item: WorkspaceClient.FileItem) {
        guard let idx = openFileItems.firstIndex(of: item) else { return }
        let closedFileItem = openFileItems.remove(at: idx)
        guard closedFileItem.id == selectedId else { return }

        if openFileItems.isEmpty {
            selectedId = nil
        } else if idx == 0 {
            selectedId = openFileItems.first?.id
        } else {
            selectedId = openFileItems[idx - 1].id
        }
    }

    var body: some View {
        NavigationView {
            if let workspaceClient = workspaceClient, let directoryURL = directoryURL {
                sidebar(workspaceClient: workspaceClient, directoryURL: directoryURL)
                    .frame(minWidth: 250)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: toggleSidebar) {
                                Image(systemName: "sidebar.leading").imageScale(.large)
                            }
                            .help("Show/Hide Sidebar")
                        }
                    }
                if openFileItems.isEmpty {
                    Text("Open file from sidebar")
                } else {
                    ZStack {
                        if let selectedId = selectedId {
                            if let selectedItem = try? workspaceClient.getFileItem(selectedId) {
                                CodeEditorView(fileURL: selectedItem.url)
                                    .padding(.top, 31.0)
                            }
                        }

                        VStack {
                            tabBar
                                .frame(maxHeight: tabBarHeight)
                                .background(Material.regular)

                            Spacer()
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(
                    action: {},
                    label: { Image(systemName: "chevron.left").imageScale(.large) }
                )
                .help("Back")
            }
            ToolbarItem(placement: .navigation) {
                Button(
                    action: {},
                    label: { Image(systemName: "chevron.right").imageScale(.large) }
                )
                .disabled(true)
                .help("Forward")
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onOpenURL { url in
            urlInit = true
            do {
                self.workspaceClient = try .default(
                    fileManager: .default,
                    folderURL: url,
                    ignoredFilesAndFolders: ignoredFilesAndDirectory
                )
                self.directoryURL = url
            } catch {
                self.alertTitle = "Unable to Open Workspace"
                self.alertMsg = error.localizedDescription
                self.showingAlert = true
                print(error.localizedDescription)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
    }

    var tabBar: some View {
        VStack(spacing: 0.0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { value in
                    HStack(alignment: .center, spacing: 0.0) {
                        ForEach(openFileItems, id: \.id) { item in
                            let isActive = selectedId == item.id

                            Button(
                                action: { selectedId = item.id },
                                label: {
                                    HStack(spacing: 0.0) {
                                        FileTabRow(fileItem: item, isSelected: isActive) {
                                            withAnimation {
                                                closeFileTab(item: item)
                                            }
                                        }

                                        Divider()
                                    }
                                    )
                                    .frame(height: tabBarHeight)
                                    .foregroundColor(isActive ? .primary : .gray)
                                    .background(isActive ? Material.bar : Material.regular)
                                    .animation(.easeOut(duration: 0.2), value: openFileItems)
                                }
                                    .buttonStyle(.plain)
                                    .id(item.id)
                                }
                                }
                                    .onChange(of: selectedId) { newValue in
                                        withAnimation {
                                            value.scrollTo(newValue)
                                        }
                                    }
                                }
                                }

                                Divider()
                                    .foregroundColor(.gray)
                                    .frame(height: 1.0)
                                }
                                }

                                func sidebar(
                                    workspaceClient: WorkspaceClient,
                                    directoryURL: URL
                                ) -> some View {
                                    List {
                                        Section(header: Text(directoryURL.lastPathComponent)) {
                                            OutlineGroup(workspaceClient.getFiles(), children: \.children) { item in
                                                if item.children == nil {
                                                    // TODO: Add selection indicator
                                                    Button(
                                                        action: {
                                                            withAnimation {
                                                                if !openFileItems.contains(item) {
                                                                    openFileItems.append(item)
                                                                }
                                                            }
                                                            selectedId = item.id
                                                        },
                                                        label: {
                                                            Label(
                                                                item.url.lastPathComponent,
                                                                systemImage: item.systemImage
                                                            )
                                                            .accentColor(.secondary)
                                                            .font(.callout)
                                                        }
                                                    )
                                                    .buttonStyle(.plain)
                                                } else {
                                                    Label(item.url.lastPathComponent, systemImage: item.systemImage)
                                                        .accentColor(.secondary)
                                                        .font(.callout)
                                                }
                                            }
                                        }
                                    }
                                }

                                private func toggleSidebar() {
#if os(iOS)
#else
                                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                                        #selector(NSSplitViewController.toggleSidebar(_:)),
                                        with: nil
                                    )
#endif
                                }
                                }

                                struct ContentView_Previews: PreviewProvider {
                                    static var previews: some View {
                                        WorkspaceView()
                                    }
                                }
