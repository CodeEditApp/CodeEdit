//
//  WorkspaceDocumentGroup.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/01/2023.
//

import SwiftUI
import WindowManagement
import CodeEditTextView

struct WorkspaceDocumentGroup: Scene {
    @Environment(\.toggleInspector) var toggleInspector
    let timer = Timer.publish(every: 3, tolerance: 2, on: .main, in: .common).autoconnect()

    var body: some Scene {

        DocumentGroup { ReferenceWorkspaceFileDocument() } editor: { doc in
            NewWorkspaceDocumentView(baseURL: doc.fileURL!)
                .environmentObject(doc.document)
                .navigationSubtitle("Main")
                .onReceive(timer) { _ in
                    guard let url = doc.fileURL else { return }
                    doc.document.checkForChanges(url: url)
                }
        }

        .commands {
            ToolbarCommands()
            SidebarCommands()

            CommandGroup(after: .sidebar) {
                Button("Toggle Inspector") {
                    toggleInspector()
                }
                .keyboardShortcut("i", modifiers: [.control, .command])
            }
        }
    }
}

extension NSColor {
    static var random: NSColor {
        return NSColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension NavigationSplitViewVisibility: RawRepresentable {
    public init?(rawValue: String) {
        print("Obtaing value from scenestorage \(rawValue)")
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(NavigationSplitViewVisibility.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        print(self)
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct NewWorkspaceDocumentView: View {

    @EnvironmentObject var document: ReferenceWorkspaceFileDocument
    @Environment(\.toggleInspector) var toggleInspector

    @State var visibility = NavigationSplitViewVisibility.automatic
    var baseURL: URL
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            NavigatorView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 300)
                .toolbar(id: "Sidebar") {

                    ToolbarItem(id: "toggleSidebarr") {
                        Button {
                            withAnimation {
                                if visibility == .all {
                                    visibility = .doubleColumn
                                } else {
                                    visibility = .all
                                }
                            }
                        } label: {
                            Image(systemName: "sidebar.left")
                        }
                        .controlSize(.large)
                    }
                }
        } content: {
            WorkspaceLayout
                .horizontal(1, .vertical(2, .horizontal(3, .one(4))))
                .toolbar(id: "Content") {
                    ToolbarItem(id: "TestButto2n", showsByDefault: false) {
                        Button("Hello2") {

                        }
                        .focusable()
                    }

                    ToolbarItem(id: "TestButton", placement: .primaryAction) {
                        Button("Hello") {

                        }
                        .focusable()
                    }
                }
        } detail: {

            Form {
                ForEach(0..<20, id: \.self) {
                    NavigationLink(String($0), value: "He")
                        .background {
                            Rectangle()
                                .fill(Color(nsColor: .random))
                        }
                }
            }
            .safeAreaInset(edge: .top) {
                Divider()
            }
            .formStyle(.grouped)


            .toolbar(id: "Detail") {
                ToolbarItem(id: "flexibleSpace", placement: .automatic) {
                    Spacer()
                }

                ToolbarItem(id: "ShowInspector") {
                    Button {
                        toggleInspector()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
            }
        }
    }
}

struct FileTreeProjectNavigator: View {
    @EnvironmentObject var doc: ReferenceWorkspaceFileDocument
    var baseURL: URL
    @State var selection: Set<FileTree> = []

    var root: FileTree {

        FileTree(wrapper: doc.baseRoot, baseURL: baseURL.deletingLastPathComponent()) { _, _ in
            FileWrapper()
        }
    }



    // TODO: fix selection by using structs to compare.
    var body: some View {
        List([root], id: \.self, children: \.children, selection: $selection) { item in
            //            OutlineGroup(, id: \.hashValue, children: \.children) { item in
            Label {
                Text(item.wrapper.filename ?? "Unknwon")
            } icon: {
                if let icon = item.wrapper.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 15)
                } else {
                    Image(systemName: "questionmark")
                }
            }
            .tag(item)
            .id(selection)

        }

        .onChange(of: selection) { newValue in

            guard let changeFile = newValue.first(where: \.wrapper.isRegularFile) else { return }

//            doc.setCurrentFile(changeFile)
            doc.setCurrentFileTree(changeFile)
        }

        .contextMenu(forSelectionType: FileTree.self) { items in
            Button("Show in Finder") {
                print("Opening \(items.map(\.url))")
                NSWorkspace.shared.activateFileViewerSelecting(items.map(\.url))
            }
        }

    }
}



struct NewNewProjectNavigator: View {
    @EnvironmentObject var doc: ReferenceWorkspaceFileDocument

    @State var selection: Set<WrappedFile> = []

    init() {

    }

    // TODO: fix selection by using structs to compare.
    var body: some View {
        List([doc.root], id: \.self, children: \.children, selection: $selection) { item in
            //            OutlineGroup(, id: \.hashValue, children: \.children) { item in
            Label {
                Text(item.filename ?? "Unknwon")
            } icon: {
                if let icon = (item as WrappedFile).icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 15)
                } else {
                    Image(systemName: "questionmark")
                }
            }
            .tag(item)

        }
        .onChange(of: selection) { newValue in
            guard let changeFile = newValue.first(where: \.isRegularFile) else { return }
            doc.setCurrentFile(changeFile)
        }

        .contextMenu(forSelectionType: WrappedFile.self) { items in
            Button("Show in Finder") {
//                    NSWorkspace.shared.activateFileViewerSelecting(items.map(\.))
            }
        }

    }
}


extension WrappedFile {
    var children: [WrappedFile]? {
        guard self.isDirectory, let values = self.fileWrappers?.values else { return nil }

        let children = Array(values).sorted {
            $0.filename! < $1.filename!
        }.map { WrappedFile($0, parent: self) }
        return children
    }
}
 
