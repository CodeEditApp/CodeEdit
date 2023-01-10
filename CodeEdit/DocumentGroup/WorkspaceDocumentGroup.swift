//
//  WorkspaceDocumentGroup.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/01/2023.
//

import SwiftUI
import CodeEditTextView

struct WorkspaceDocumentGroup: Scene {

    let timer = Timer.publish(every: 3, tolerance: 2, on: .main, in: .common).autoconnect()

    var body: some Scene {

        DocumentGroup { ReferenceWorkspaceFileDocument() } editor: { doc in
            NewWorkspaceDocumentView(baseURL: doc.fileURL!)
                .environmentObject(doc.document)
                .task {
                    NSApp.windows.forEach { window in
                        let index = window.toolbar?.items.firstIndex {
                            $0.itemIdentifier == .init("com.apple.SwiftUI.navigationSplitView.toggleSidebar")
                        }
                        if let index {
                            window.toolbar?.removeItem(at: index)
                        }
                    }
                }
                .onReceive(timer) { _ in
                    guard let url = doc.fileURL else { return }
                    doc.document.checkForChanges(url: url)
                }
        }
    }
}

struct NewWorkspaceDocumentView: View {

    @EnvironmentObject var document: ReferenceWorkspaceFileDocument
    var baseURL: URL
    var body: some View {
        let _ = Self._printChanges()
        NavigationSplitView {
//            NewNewProjectNavigator()
            FileTreeProjectNavigator(baseURL: baseURL)
        } detail: {
            WorkspaceLayout
                .horizontal(1, .vertical(2, .horizontal(3, .one(4))))
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
 
