//
//  BreadcrumbsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsView: View {
    @ObservedObject
    var workspace: WorkspaceDocument

<<<<<<< HEAD
    let file: WorkspaceClient.FileItem

    @State
    private var projectName: String = ""

	@State
	private var fileItems: [WorkspaceClient.FileItem] = []

    @State
    private var folders: [String] = []

    @State
    private var fileName: String = ""

    @State
    private var fileImage: String = "doc"

    init(_ file: WorkspaceClient.FileItem, workspace: WorkspaceDocument) {
        self.file = file
        self.workspace = workspace
    }

=======
    @ObservedObject var workspace: WorkspaceDocument
    let file: WorkspaceClient.FileItem

    @State private var projectName: String = ""
    @State private var fileItems: [WorkspaceClient.FileItem] = []
    @State private var folders: [String] = []
    @State private var fileName: String = ""
    @State private var fileImage: String = "doc"

    init(_ file: WorkspaceClient.FileItem, workspace: WorkspaceDocument) {
        self.file = file
        self.workspace = workspace
    }

>>>>>>> 5ed6842 (Adjust indent)
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundStyle(Color(nsColor: .controlBackgroundColor))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(fileItems, id: \.self) { fileItem in
                        if fileItem.parent != nil {
                            chevron
                        }
                        let color = fileItem.parent == nil
                            ? .accentColor
                            : fileItem.children?.isEmpty ?? true
                                ? fileItem.iconColor
                                : .secondary
                        BreadcrumbsMenu(workspace,
                                        title: fileItem.fileName,
                                        systemImage: fileItem.parent == nil
                                            ? "square.dashed.inset.filled"
                                            : fileItem.systemImage,
                                        color: color,
                                        parentFileItem: fileItem.parent)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 29)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .onAppear {
            fileInfo(self.file)
        }
        .onChange(of: file) { newFile in
            fileInfo(newFile)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .foregroundStyle(.secondary)
            .imageScale(.large)
    }

    private func fileInfo(_ file: WorkspaceClient.FileItem) {
  		self.fileItems = []
		var currentFile: WorkspaceClient.FileItem? = file
		while currentFile != nil {
			self.fileItems.insert(currentFile!, at: 0)
			currentFile = currentFile!.parent
		}      
		guard let projURL = workspace.fileURL else { return }
        let components = file.url.path
            .replacingOccurrences(of: projURL.path, with: "")
            .split(separator: "/")
            .map { String($0) }
            .dropLast()

        self.projectName = projURL.lastPathComponent
        self.folders = Array(components)
        self.fileName = file.fileName
        self.fileImage = file.systemImage
    }
}

struct BreadcrumbsView_Previews: PreviewProvider {
    static var previews: some View {
        BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.dark)

        BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.light)
    }
}
